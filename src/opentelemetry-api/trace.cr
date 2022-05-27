require "../proto/trace.pb"
require "../proto/trace_service.pb"
require "./span"
require "random/pcg32"
require "./trace/exceptions"
require "./sendable"

module OpenTelemetry
  class Trace
    include Sendable

    @@prng = Random::PCG32.new

    property trace_id : Slice(UInt8) = @@prng.random_bytes(16)
    @service_name : String = ""
    @service_version : String = ""
    property schema_url : String = ""
    # property exporter : Exporter? = nil
    @exporter : Exporter? = nil
    getter provider : TraceProvider
    getter span_stack : Array(Span) = [] of Span
    getter output_stack : Deque(Span) = Deque(Span).new
    @root_span : Span? = nil
    getter resource : Resource = Resource.new
    property current_span : Span? = nil
    property span_context : SpanContext = SpanContext.new
    @exported : Bool = false
    @lock : Mutex = Mutex.new(protection: :reentrant)

    MATCH = /(?<trace_id>[A-Fa-f0-9]{32})/

    # This returns the currently initialized random number generator. The Crystal
    # OpenTelemetry currently utilizes only the PCG32 algorithm, as in earlier
    # versions of Crystal, the Random::ISAAC algorithm, which is arguably superior
    # to the PCG32 algorithm, was not concurrency-safe, and would cause strange and
    # unpleasant problems under heavy concurrent loads. If/when it is determined that
    # this is no longer an issue, the library will support both algorithms, but will
    # default to the ISAAC algorithm.
    def self.prng : Random::PCG32
      @@prng
    end

    # Returns the currently active `Tracer` in the current fiber, or nil if there is no currently active `Tracer`.
    def self.current_trace
      Fiber.current.current_trace
    end

    # Returns the current active `Span` in the current fiber, or nil if there is no currently
    # active `Span`.
    def self.current_span
      Fiber.current.current_span
    end

    # Take a slice of UInt8 (`Bytes`) and determine if it is a valid trace_id.
    def self.validate_id(id : Slice(Uint8))
      validate_id(id.hexstring)
    end

    # Take a string and determine if it is a valid trace_id.
    def self.validate_id(id : String)
      !!MATCH.match id
    end

    def initialize(
      service_name = nil,
      service_version = nil,
      schema_url = nil,
      exporter = nil,
      provider = nil
    )
      provider ||= TraceProvider.new
      @provider = provider
      self.provider = provider
      self.service_name = service_name if service_name
      self.service_version = service_version if service_version
      self.schema_url = schema_url if schema_url
      self.trace_id = @provider.id_generator.trace_id
      span_context.trace_id = trace_id
      set_standard_resource_attributes
    end

    # This returns the exporter that this trace will be exported to.
    def exporter
      @provider.config.exporter
    end

    # Set an attribute on the `Resource` that is attached to this trace.
    def []=(key, value)
      resource[key] = value
    end

    # An alias for `#[]=`
    def set_attribute(key, value)
      resource[key] = value
    end

    # Get the value of an attribute on the `Resource` that is attached to this trace. This will throw an exception if the key does not exist.
    def [](key)
      resource[key].value
    end

    # An alias for `#[]`
    def get_attribute(key)
      resource[key]
    end

    # Get the value of an attribute on the `Resource` that is attached to this trace, or nil if the key does not exist.
    def []?(key)
      if r = resource[key]?
        r.value
      else
        nil
      end
    end

    # Return the service name of this trace.
    def service_name
      @service_name
    end

    # Set the service name of this trace.
    def service_name=(val)
      @service_name = val
      self["service.name"] = val
    end

    # Return the service version of this trace.
    def service_version
      @service_version
    end

    # Set the service version of this trace.
    def service_version=(val)
      @service_version = val
      self["service.version"] = val
    end

    # Return the trace_id for this trace.
    def id
      trace_id
    end

    # Set the `TraceProvider` for this trace.
    def provider=(val)
      self.service_name = @provider.service_name
      self.service_version = @provider.service_version
      self.schema_url = @provider.schema_url
      @provider = val
    end

    # Merge the configuration from a given `TraceProvider` into the configuration for this trace's TraceProvider.
    def merge_configuration_from_provider=(val)
      self.service_name = val.service_name if self.service_name.nil? || self.service_name.empty?
      self.service_version = val.service_version if self.service_version.nil? || self.service_version.empty?
      self.schema_url = val.schema_url if self.schema_url.nil? || self.schema_url.empty?
      @provider = val
    end

    # Start a new span in the current trace. A matching `#close_span` call *must* be made to complete the span.
    def in_span(span_name)
      @lock.lock

      in_span_impl span_name
    end

    # Start a new span in the current trace. The block provided will be executed within the context of the new span,
    # and the span will be closed automatically when the block returns.
    def in_span(span_name)
      @lock.synchronize do
        span = in_span_impl(span_name)

        exception = nil
        current_trace = Fiber.current.current_trace.not_nil!
        begin
          result = yield span
        rescue exception
          unless exception.span_status_message_set
            # If there was an error, then we have to set the span status accordingly, and set the message.
            span.status.error!(exception.message)
            span.add_event("exception") do |event|
              event["exception.type"] = exception.class.name
              event["exception.message"] = exception.message.to_s
              event["exception.backtrace"] = exception.backtrace.join("\n")
            end
            current_trace.span_context["exception.type"] = exception.class.name
            current_trace.span_context["exception.message"] = exception.message.to_s
            current_trace.span_context["exception.stacktrace"] = exception.backtrace.join("\n")
            exception.span_status_message_set = true
          end
        end

        if !exception && ((span == @root_span) && current_trace.span_context.trace_state.has_key?("exception.type"))
          span.status.error!(current_trace.span_context["exception.message"])
          span.add_event("exception") do |event|
            event["exception.type"] = current_trace.span_context["exception.type"]
            event["exception.message"] = current_trace.span_context["exception.message"]
            event["exception.stacktrace"] = current_trace.span_context["exception.stacktrace"]
          end
        end

        close_span_impl(span)

        raise exception if exception

        begin
          result.as(typeof(yield span)) # `typeof` is evaluated at compile_time, which means that the yield is not actually called twice, despite what this looks like.
        rescue ex : TypeCastError
          # Sometimes, the above still fails to protect us. I feel like there has to be a better way to do this, but for now, this works.
          result.not_nil!
        end
      end
    end

    @[AlwaysInline]
    private def in_span_impl(span_name)
      span = Span.build(span_name) do |spx|
        spx.context = SpanContext.build(@span_context) do |ctx|
          ctx.span_id = @provider.id_generator.span_id
        end
      end

      # TODO: Is there a more efficient way to do this than creating and throwing away
      # multiple Span::Context structs?
      span.context = set_sampling(span)

      if @root_span.nil? || @exported
        Fiber.current.current_trace = self
        @exported = false
        @root_span = Fiber.current.current_span = @current_span = span
      else
        span_parent = @span_stack.last
        span.parent = span_parent
        span.context.parent_id = span_parent.try &.span_id
        span.is_recording = span_parent.is_recording # Propagate is_recording to children.
        # @span_stack.last.children << span
        Fiber.current.current_span = @current_span = span
      end
      @span_stack << span

      span
    end

    @[AlwaysInline]
    def set_sampling(span)
      ctx = span.context
      case @provider.config.sampler.should_sample(span).decision
      when OpenTelemetry::Sampler::SamplingResult::Decision::RecordAndSample
        span.is_recording = true
        ctx.trace_flags = OpenTelemetry::TraceFlags::Sampled
      when OpenTelemetry::Sampler::SamplingResult::Decision::RecordOnly
        span.is_recording = true
        ctx.trace_flags = OpenTelemetry::TraceFlags::None
      else
        span.is_recording = false
        ctx.trace_flags = OpenTelemetry::TraceFlags::None
      end

      ctx
    end

    @[AlwaysInline]
    private def close_span_impl(span)
      span.finish = Time.monotonic
      span.wall_finish = Time.utc
      if @span_stack.last == span
        candidate_span = @span_stack.pop
        @output_stack.unshift(candidate_span) if candidate_span.can_export?
        Fiber.current.current_span = @current_span = @span_stack.last?
      else
        raise InvalidSpanInSpanStackError.new(span_stack.last.inspect, span.inspect)
      end
      if span == @root_span && !@exported # && (_exporter = @exporter)
        if _exporter = exporter
          # TODO: Re-examine how this works. Currently, all spans,
          # even those which have been sampled out, are sent to the
          # exporter, but the ones which are sampled out won't get
          # sent. It would be better if the ones which are sampled
          # out just go away early.
          _exporter.export self
        end
        @root_span = nil
        @exported = true
        Fiber.current.current_trace = nil
        Fiber.current.current_span = nil
      end
    end

    # Close a previosly opened span.
    def close_span(span = OpenTelemetry.current_span)
      return unless span

      close_span_impl(span)
    ensure
      @lock.unlock
    end

    private def set_standard_resource_attributes
      self["service.name"] = service_name
      self["service.version"] = service_version
      self["service.instance.id"] = OpenTelemetry::INSTANCE_ID
    end

    private def iterate_span_nodes(span, buffer)
      iterate_span_nodes(span) do |s|
        buffer << s if s && s.can_export?
      end

      buffer
    end

    private def iterate_span_nodes(span, &blk : Span? ->)
      yield span if span
      if span && span.children
        span.children.each do |child|
          iterate_span_nodes(child, &blk) if child
        end
      end
    end

    private def reverse_iterate_span_nodes(span, &blk : Span? ->)
      if span && span.children
        span.children.each do |child|
          reverse_iterate_span_nodes(child, &blk) if child
        end
      end
      yield span if span
    end

    # This method returns a ProtoBuf object containing all of the Trace information.
    def to_protobuf
      spans_buffer = @output_stack.compact_map(&.to_protobuf)
      return if spans_buffer.empty?

      Proto::Trace::V1::ResourceSpans.new(
        resource: resource.to_protobuf,
        scope_spans: [
          Proto::Trace::V1::ScopeSpans.new(
            scope: OpenTelemetry.instrumentation_scope,
            spans: spans_buffer
          ),
        ],
        schema_url: schema_url
      )
    end

    def to_json
      # return "" unless iterate_span_nodes(root_span, [] of Span).any?(&.can_export?)
      return "" unless @output_stack.any?(&.can_export?)

      String.build do |json|
        json << "{\n"
        json << "  \"type\":\"trace\",\n"
        json << "  \"traceId\":\"#{trace_id.hexstring}\",\n"
        if !resource.empty?
          json << "  \"resource\":{\n"
          json << resource.attribute_list
          json << "\n  },\n"
        end
        json << "  \"schemaUrl\":\"#{schema_url}\",\n" if !schema_url.empty?
        json << "  \"spans\":[\n"
        json << String.build do |span_list|
          # iterate_span_nodes(root_span) do |span|
          @output_stack.each do |span|
            span_list << "    "
            span_list << span.to_json if span
            span_list << ",\n"
          end
        end.chomp(",\n")
        json << "\n  ]\n"
        json << "}"
      end
    end
  end

  # Alias. The spec uses `TracerProvider`s, which manage `Tracer`s,
  # but which have internal methods and entities like `trace_id` and `TraceState`
  # and `TraceFlags`. Then this library was initially written, I opted for uniformly
  # consistent naming, but that violates the spec. Future versions will move towards
  # deprecating the uniform naming, in places where that naming violates the spec.
  # This is here to start preparing for that transition.
  alias Tracer = Trace
end

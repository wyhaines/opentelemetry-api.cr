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
    getter root_span : Span? = nil
    getter resource : Resource = Resource.new
    property current_span : Span? = nil
    property span_context : SpanContext = SpanContext.new
    @exported : Bool = false
    @lock : Mutex = Mutex.new(protection: :reentrant)

    MATCH = /(?<trace_id>[A-Fa-f0-9]{32})/

    def self.prng : Random::PCG32
      @@prng
    end

    def self.current_trace
      Fiber.current.current_trace
    end

    def self.current_span
      Fiber.current.current_span
    end

    def self.validate_id(id : Slice(Uint8))
      validate_id(id.hexstring)
    end

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

    def exporter
      @provider.config.exporter
    end

    def []=(key, value)
      resource[key] = value
    end

    def set_attribute(key, value)
      resource[key] = value
    end

    def [](key)
      resource[key].value
    end

    def get_attribute(key)
      resource[key]
    end

    def service_name
      @service_name
    end

    def service_name=(val)
      @service_name = val
      self["service.name"] = val
    end

    def service_version
      @service_version
    end

    def service_version=(val)
      @service_version = val
      self["service.version"] = val
    end

    def id
      trace_id
    end

    def provider=(val)
      self.service_name = @provider.service_name
      self.service_version = @provider.service_version
      self.schema_url = @provider.schema_url
      @provider = val
    end

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
        begin
          result = yield span
        rescue exception
          unless exception.span_status_message_set
            # If there was an error, then we have to set the span status accordingly, and set the message.
            span.status.error!(exception.message)
            exception.span_status_message_set = true
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

    private def in_span_impl(span_name)
      span = Span.new(span_name)
      span.context = SpanContext.build(@span_context) do |ctx|
        ctx.span_id = @provider.id_generator.span_id
      end
  
      # TODO: Is there a more efficient way to do this than creating and throwing away
      # multiple Span::Context structs?
      span.context = set_sampling(span)

      if @root_span.nil? || @exported
        Fiber.current.current_trace = self
        @exported = false
        @root_span = Fiber.current.current_span = @current_span = span
      else
        span.parent = @span_stack.last
        span.context.parent_id = span.parent.try &.span_id
        span.is_recording = @span_stack.last.is_recording # Propagate is_recording to children.
        @span_stack.last.children << span
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

    private def close_span_impl(span)
      span.finish = Time.monotonic
      span.wall_finish = Time.utc
      if @span_stack.last == span
        @span_stack.pop
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
        @exported = true
        Fiber.current.current_trace = nil
        Fiber.current.current_span = nil
      end
    end

    # Close a previosly opened span.
    def close_span(span = OpenTelemetry.current_span)
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
        buffer << s if s && s.recording?
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

    # TODO: Add support for a Resource
    # This method returns a ProtoBuf object containing all of the Trace information.
    def to_protobuf
      spans_buffer = iterate_span_nodes(root_span, [] of Span).map(&.to_protobuf.not_nil!)
      return if spans_buffer.empty?
      pp "SPANS BUFFER HAS #{spans_buffer.size}"
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
      return "" unless iterate_span_nodes(root_span, [] of Span).any? {|spn| spn.can_export?}
      String.build do |json|
        json << "{\n"
        json << "  \"type\":\"trace\",\n"
        json << "  \"traceId\":\"#{trace_id.hexstring}\",\n"
        if !resource.empty?
          json << "  \"resource\":{\n"
          json << resource.attribute_list
          json << "  },\n"
        end
        json << "  \"schemaUrl\":\"#{schema_url}\",\n" if !schema_url.empty?
        json << "  \"spans\":[\n"
        json << String.build do |span_list|
          iterate_span_nodes(root_span) do |span|
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

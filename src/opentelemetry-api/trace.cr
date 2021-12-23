require "../proto/trace.pb"
require "../proto/trace_service.pb"
require "./span"
require "random/isaac"

module OpenTelemetry
  class Trace
    @@prng = Random::ISAAC.new

    property trace_id : Slice(UInt8) = @@prng.random_bytes(16)
    property service_name : String = ""
    property service_version : String = ""
    property exporter : Exporter = Exporter.new(:abstract)
    getter provider : TraceProvider = TraceProvider.new
    getter span_stack : Array(Span) = [] of Span
    getter root_span : Span? = nil
    property current_span : Span? = nil
    property span_context : SpanContext = SpanContext.new
    @exported : Bool = false
    @lock : Mutex = Mutex.new

    def self.prng : Random::ISAAC
      @@prng
    end

    def initialize(
      service_name = nil,
      service_version = nil,
      exporter = nil,
      provider = nil
    )
      self.provider = provider if provider
      self.service_name = service_name if service_name
      self.service_version = service_version if service_version
      self.exporter = exporter if exporter
      self.trace_id = @provider.id_generator.trace_id
      span_context.trace_id = trace_id
    end

    def id
      trace_id
    end

    def provider=(val)
      self.service_name = @provider.service_name
      self.service_version = @provider.service_version
      self.exporter = @provider.exporter
      @provider = val
    end

    def merge_configuration_from_provider=(val)
      self.service_name = val.service_name if self.service_name.nil? || self.service_name.empty?
      self.service_version = val.service_version if self.service_version.nil? || self.service_version.empty?
      self.exporter = val.exporter if self.exporter.nil? || self.exporter.exporter.is_a?(Exporter::Abstract)
      @provider = val
    end

    def in_span(span_name)
      span = Span.new(span_name)
      span.context = SpanContext.new(@span_context) do |ctx|
        ctx.span_id = @provider.id_generator.span_id
      end

      if @root_span.nil? || @exported
        @exported = false
        @root_span = @current_span = span
      else
        span.parent = @span_stack.last
        @span_stack.last.children << span
        @current_span = span
      end
      @span_stack << span
      yield span
      span.finish = Time.monotonic
      span.wall_finish = Time.utc
      if @span_stack.last == span
        @span_stack.pop
        @current_span = @span_stack.last?
      else
        raise "Unexpected Error: Invalid Spans in the Span Stack. Expected #{span.inspect} but found #{span_stack.last.inspect}"
      end

      if span == @root_span && !@exported
        @exporter.export self
        @exported = true
      end
    end

    private def iterate_span_nodes(span, buffer)
      iterate_span_nodes(span) do |s|
        buffer << s if s
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

    # This method returns a ProtoBuf object containing all of the Trace information.
    def to_protobuf
      Proto::Trace::V1::ResourceSpans.new(
        instrumentation_library_spans: [
          Proto::Trace::V1::InstrumentationLibrarySpans.new(
            instrumentation_library: Proto::Common::V1::InstrumentationLibrary.new(
              name: "OpenTelemetry Crystal",
              version: VERSION,
            ),
            spans: iterate_span_nodes(root_span, [] of Span).map(&.to_protobuf)
          ),
        ],
      )
    end

    def to_json
      String.build do |json|
        json << "{\n"
        json << "  \"type\":\"trace\",\n"
        json << "  \"traceId\":\"#{trace_id.hexstring}\",\n"
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
end
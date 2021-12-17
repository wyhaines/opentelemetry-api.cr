require "./span"
require "random/isaac"

module OpenTelemetry
  class Tracer
    @@prng = Random::ISAAC.new

    getter trace_id : Slice(UInt8)
    property service_name : String = ""
    property service_version : String = ""
    property exporter : Exporter = AbstractExporter.new
    getter provider : TracerProvider = TracerProvider.new
    getter span_stack : Array(Span) = [] of Span
    getter root_span : Span? = nil
    property current_span : Span? = nil
    property span_context : SpanContext = SpanContext.new

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

    def provider=(val)
      self.service_name = @provider.service_name
      self.service_version = @provider.service_version
      self.exporter = @provider.exporter
      @provider = val
    end

    def merge_configuration_from_provider=(val)
      self.service_name = val.service_name if self.service_name.nil? || self.service_name.empty?
      self.service_version = val.service_version if self.service_version.nil? || self.service_version.empty?
      self.exporter = val.exporter if self.exporter.nil? || self.exporter.is_a?(AbstractExporter)
      @provider = val
    end

    def in_span(span_name)
      span = Span.new(span_name)
      span.context = @span_context
      if @root_span.nil?
        @root_span = @current_span = span
      else
        span.parent = @span_stack.last
        @span_stack.last.children << span
        @current_span = span
      end
      @span_stack << span
      yield span
      if @span_stack.last == span
        @span_stack.pop
        @current_span = @span_stack.last?
      else
        raise "Unexpected Error: Invalid Spans in the Span Stack. Expected #{span.inspect} but found #{span_stack.last.inspect}"
      end
    end
  end
end

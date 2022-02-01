require "./provider"
require "./trace"

module OpenTelemetry
  # A TraceProvider encapsulates a set of tracing configuration, and provides an interface for creating Trace instances.
  class TraceProvider < Provider
    def trace
      new_trace = Trace.new
      new_trace.provider = self

      new_trace
    end

    def trace(
      service_name = nil,
      service_version = nil,
      exporter = nil,
      id_generator = nil
    )
      new_trace = Trace.new(service_name, service_version, exporter, id_generator)
      new_trace.merge_configuration_from_provider = self

      new_trace
    end

    def trace
      new_trace = trace
      new_trace.provider = self
      yield new_trace

      new_trace
    end
  end
end

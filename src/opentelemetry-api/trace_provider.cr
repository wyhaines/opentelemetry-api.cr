require "./provider"
require "./trace"

module OpenTelemetry
  # A TraceProvider encapsulates a set of tracing configuration, and provides an interface for creating Trace instances.
  class TraceProvider < Provider
    def trace(
      service_name = nil,
      service_version = nil,
      schema_url = nil,
      exporter = nil,
      provider = self
    )
      new_trace = Trace.new(
        service_name: service_name,
        service_version: service_version,
        schema_url: schema_url,
        exporter: exporter,
        provider: provider)
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

require "./provider"
require "./trace"
require "./sampler" # SDK

module OpenTelemetry
  # A TraceProvider encapsulates a set of tracing configuration, and provides an interface for creating Trace instances.
  class TraceProvider < Provider
    # # Ensure that any resources, like fibers, are shut down when a TracerProvider object is collected.
    # def finalize
    #   @config.exporter.try(&.exporter).try(&.do_reap)
    # end

    # Create a new trace, initializing it with the provided parameters.
    def trace(
      service_name = nil,
      service_version = nil,
      schema_url = nil,
      provider = self
    )
      new_trace = Trace.new(
        service_name: service_name,
        service_version: service_version,
        schema_url: schema_url,
        provider: provider)
      new_trace.merge_configuration_from_provider = self

      new_trace
    end

    # Alias. The spec uses `TracerProvider`s, which manage `Tracer`s,
    # but which have internal methods and entities like `trace_id` and `TraceState`
    # and `TraceFlags`. Then this library was initially written, I opted for uniformly
    # consistent naming, but that violates the spec. Future versions will move towards
    # deprecating the uniform naming, in places where that naming violates the spec.
    # This is here to start preparing for that transition.
    def tracer(
      service_name = nil,
      service_version = nil,
      schema_url = nil,
      provider = self
    )
      trace(service_name, service_version, schema_url, provider)
    end

    # Create a new, uninitialized trace, and pass it to the provided block to
    # complete its initialization.
    def trace
      new_trace = trace
      new_trace.provider = self
      yield new_trace

      new_trace
    end

    # Alias. The spec uses `TracerProvider`s, which manage `Tracer`s,
    # but which have internal methods and entities like `trace_id` and `TraceState`
    # and `TraceFlags`. Then this library was initially written, I opted for uniformly
    # consistent naming, but that violates the spec. Future versions will move towards
    # deprecating the uniform naming, in places where that naming violates the spec.
    # This is here to start preparing for that transition.
    def tracer
      new_trace = trace
      new_trace.provider = self
      yield new_trace

      new_trace
    end
  end

  # Alias. The spec uses `TracerProvider`s, which manage `Tracer`s,
  # but which have internal methods and entities like `trace_id` and `TraceState`
  # and `TraceFlags`. Then this library was initially written, I opted for uniformly
  # consistent naming, but that violates the spec. Future versions will move towards
  # deprecating the uniform naming, in places where that naming violates the spec.
  # This is here to start preparing for that transition.
  alias TracerProvider = TraceProvider
end

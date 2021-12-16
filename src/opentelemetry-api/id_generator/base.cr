module OpenTelemetry
  # This is the abstract base implementation for an ID Generator. Other ID Generators
  # should inherit from this class to implement the interface prescribed here.
  struct IdGenerator
    abstract struct Base
      # This method will return an ID suitable for use as a Trace ID. The standard offered
      # in the open telemetry spec is 128 bits (16 bytes). This is not a hard requirement,
      # however, so subclass implementations can return a different length.
      abstract def trace_id

      # This method will return an ID suitable for use as a Span ID. The standard offered
      # in the open telemetry spec is 64 bits (8 bytes). This is not a hard requirement,
      # however, so subclass implementations can return a different length.
      abstract def span_id
    end
  end
end

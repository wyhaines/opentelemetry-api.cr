module OpenTelemetry
  # This is the abstract base implementation for an ID Generator. Other ID Generators
  # should inherit from this class to implement the interface prescribed here.
  abstract struct IdGenerator::Base
    # This method will return an ID suitable for use as a Trace ID. The standard offered
    # in the open telemetry spec is 128 bits (16 bytes). This is not a hard requirement,
    # however, so subclass implementations can return a different length.
    # The base implementation just returns a random sequence of bytes.
    def self.trace_id
      Bytes.random(16)
    end

    # This method will return an ID suitable for use as a Span ID. The standard offered
    # in the open telemetry spec is 64 bits (8 bytes). This is not a hard requirement,
    # however, so subclass implementations can return a different length.
    # The base implementation just returns a random sequence of bytes.
    def self.span_id
      Bytes.random(8)
    end
  end
end
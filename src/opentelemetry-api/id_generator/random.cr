require "./base"

module OpenTelemetry
  struct IdGenerator::Random < IdGenerator::Base
    # Return a random sequence of 16 bytes for the trace id.
    def trace_id
      Trace.prng.random_bytes(16)
    end

    # Return a random sequence of 8 bytes for the span id.
    def span_id
      Trace.prng.random_bytes(8)
    end
  end
end

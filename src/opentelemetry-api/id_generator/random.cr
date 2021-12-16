require "./base"

module OpenTelemetry
  struct IdGenerator::Random < IdGenerator::Base
    # Return a random sequence of 16 bytes for the trace id.
    def trace_id
      Bytes.random(16)
    end

    # Return a random sequence of 8 bytes for the span id.
    def span_id
      Bytes.random(8)
    end
  end
end

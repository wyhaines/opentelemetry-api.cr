require "bit_array"

module OpenTelemetry
  class SpanContext
    property trace_id : Slice(UInt8)
    property span_id : Slice(UInt8)
    getter trace_flags : BitArray = BitArray.new(8)
    getter trace_state : Hash(String, String) = {} of String => String

    def initialize
      @trace_id = Slice(UInt8).new(8,0)
      @span_id = Tracer.prng.random_bytes(8)
    end

    def initialize(@trace_id, @span_id, @trace_flags, @trace_state)
    end
  end
end

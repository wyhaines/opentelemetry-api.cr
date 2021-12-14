require "bit_array"

module OpenTelemetry
  class SpanContext
    getter trace_id : CSUUID
    getter span_id : CSUUID
    getter trace_flags : BitArray = BitArray.new(8)
    getter trace_state : Hash(String, String) = {} of String => String
  end
end
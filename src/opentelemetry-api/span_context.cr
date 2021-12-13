require "bit_array"

module OpenTelemetry
  class SpanContext
    getter trace_id : CSUUID
    getter span_id : CSUUID
    getter trace_flags : BitArray(8) = BitArray(8).new
    getter trace_state : Hash(String, String) = {} of String => String
  end
end
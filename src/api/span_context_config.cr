require "./abstract_span_context_config"

module OpenTelemetry
  module API
    struct SpanContext < AbstractSpanContext
      class Config < AbstractSpanContext::AbstractConfig
        property trace_id : Slice(UInt8)
        property span_id : Slice(UInt8)
        property parent_id : Slice(UInt8)? = nil
        property trace_flags : TraceFlags
        property trace_state : Hash(String, String) = {} of String => String
        property remote : Bool = false

        def initialize(@trace_id, @span_id, @parent_id = nil)
          @trace_flags = TraceFlags.new(0x00)
        end

        def initialize(inherited_context : SpanContext)
          @trace_id = inherited_context.trace_id
          @trace_state = inherited_context.trace_state
          @trace_flags = inherited_context.trace_flags
          @remote = inherited_context.remote
          @span_id = Slice(UInt8).new(8)
          @parent_id = inherited_context.span_id
        end
      end
    end
  end
end

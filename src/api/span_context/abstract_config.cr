require "../trace_flags"

module OpenTelemetry
  module API
    abstract struct AbstractSpanContext
      abstract class AbstractConfig
        abstract def initialize(@trace_id, @span_id, @parent_id = nil)

        abstract def initialize(inherited_context : SpanContext)

        # Likely defined as a property
        abstract def trace_id : Slice(UInt8)
        abstract def trace_id=(trace_id : Slice(UInt8))

        # Likely defined as a property
        abstract def span_id : Slice(UInt8)
        abstract def span_id=(span_id : Slice(UInt8))

        # Likely defined as a property
        abstract def parent_id : Slice(UInt8)?
        abstract def parent_id=(parent_id : Slice(UInt8)?)

        # Likely defined as a property
        abstract def trace_flags : TraceFlags
        abstract def trace_flags=(trace_flags : TraceFlags)

        # Likely defined as a property
        abstract def trace_state : Hash(String, String)
        abstract def trace_state=(trace_state : Hash(String, String))

        # Likely defined as a property
        abstract def remote : Bool
        abstract def remote=(remote : Bool)
      end
    end
  end
end

require "./span_context/abstract_config"

module OpenTelemetry
  module API
    abstract struct AbstractSpanContext
      abstract def initialize

      abstract def initialize(@trace_id, @span_id, @parent_id, @trace_flags, @trace_state, @remote = false)

      abstract def initialize(inherited_context : SpanContext)

      abstract def initialize(configuration : Config)

      # This is probably going to be a property
      abstract def trace_id : Slice(UInt8)
      abstract def trace_id=(trace_id : Slice(UInt8))

      # This is probably going to be a property
      abstract def span_id : Slice(UInt8)
      abstract def span_id=(span_id : Slice(UInt8))

      # This is probably going to be a property
      abstract def parent_id : Slice(UInt8)?
      abstract def parent_id=(parent_id : Slice(UInt8)?)

      # This is probably going to be a property
      abstract def trace_flags : TraceFlags
      abstract def trace_flags=(trace_flags : TraceFlags)

      # NOTE: We're currenty playing fast and loose with TraceState. TraceState, per the spec,
      # should be immutable, however, so this will need to be revised.
      # This is probably going to be a property
      abstract def trace_state : Hash(String, String)
      abstract def trace_state=(trace_state : Hash(String, String))

      # This is probably going to be a property
      abstract def remote : Bool
      abstract def remote=(remote : Bool)

      # Returns true is the trace id and span id are non-zero
      abstract def valid?

      # The spec dictates that this name be available: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md#isvalid
      abstract def is_valid

      abstract def remote?

      # The spec dictates that this name be available: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md#isvalid
      abstract def is_remote

      abstract def [](val)

      abstract def []?(val)

      abstract def []=(val, val2)

      def self.build(inherited_context : SpanContext? = nil)
      end
    end
  end
end

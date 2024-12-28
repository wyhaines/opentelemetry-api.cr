require "./span_context/config"

module OpenTelemetry
  module API
    struct SpanContext < AbstractSpanContext
      property trace_id : Slice(UInt8)
      property span_id : Slice(UInt8)
      property parent_id : Slice(UInt8)? = nil
      property trace_flags : TraceFlags = TraceFlags::Sampled
      # TODO: We're currenty playing fast and loose with TraceState. TraceState, per the spec,
      # should be immutable, however, so this will need to be revised.
      property trace_state : Hash(String, String) = {} of String => String
      # ameba:disable Style/QueryBoolMethods
      property remote : Bool = false

      def initialize
        @trace_id = Slice(UInt8).new(16, 0)
        @span_id = Slice(UInt8).new(8, 0)
        @trace_flags = TraceFlags.new(0x00)
      end

      def initialize(@trace_id, @span_id, @parent_id, @trace_flags, @trace_state, @remote = false)
      end

      def initialize(configuration : Config)
        initialize(
          configuration.trace_id,
          configuration.span_id,
          configuration.parent_id,
          configuration.trace_flags,
          configuration.trace_state,
          configuration.remote)
      end

      def initialize(inherited_context : SpanContext)
        @trace_id = inherited_context.trace_id
        @trace_state = inherited_context.trace_state
        @trace_flags = inherited_context.trace_flags
        @remote = inherited_context.remote
        @span_id = Slice(UInt8).new(8, 0)
        @parent_id = inherited_context.span_id
      end

      # Returns true is the trace id and span id are non-zero
      def valid?
      end

      # The spec dictates that this name be available: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md#isvalid
      def is_valid
        valid?
      end

      def remote?
      end

      # The spec dictates that this name be available: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md#isvalid
      def is_remote
        remote?
      end

      def [](val)
      end

      def []?(val)
      end

      def []=(val, val2)
      end

      def self.build(inherited_context : SpanContext? = nil, &)
        if inherited_context
          config = Config.new(inherited_context)
        else
          config = Config.new(Slice(UInt8).new(16, 0), IdGenerator.span_id)
        end

        yield config

        new(config)
      end
    end
  end
end

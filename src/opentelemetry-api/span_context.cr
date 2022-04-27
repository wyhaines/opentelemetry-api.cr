require "bit_array"

module OpenTelemetry
  struct SpanContext
    property trace_id : Slice(UInt8)
    property span_id : Slice(UInt8)
    property trace_flags : TraceFlags
    property trace_state : Hash(String, String) = {} of String => String
    property remote : Bool = false

    def initialize
      @trace_id = Slice(UInt8).new(16, 0)
      @span_id = Slice(UInt8).new(8, 0)
      @trace_flags = TraceFlags.new(0x00)
    end

    def initialize(@trace_id, @span_id, @trace_flags, @trace_state, @remote = false)
    end

    def initialize(inherited_context : SpanContext)
      @trace_id = inherited_context.trace_id
      @trace_state = inherited_context.trace_state
      @trace_flags = inherited_context.trace_flags
      @remote = inherited_context.remote
      @span_id = IdGenerator.span_id
    end

    def initialize(configuration : Config)
      initialize(
        configuration.trace_id,
        configuration.span_id,
        configuration.trace_flags,
        configuration.trace_state,
        configuration.remote)
    end

    def self.build(inherited_context : SpanContext? = nil)
      if inherited_context
        config = Config.new(inherited_context)
      else
        config = Config.new(Slice(UInt8).new(16, 0), IdGenerator.span_id)
      end

      yield config

      new(config)
    end

    class Config
      property trace_id : Slice(UInt8)
      property span_id : Slice(UInt8)
      property trace_flags : TraceFlags
      property trace_state : Hash(String, String) = {} of String => String
      property remote : Bool = false

      def initialize(@trace_id, @span_id)
        @trace_flags = TraceFlags.new(0x00)
      end

      def initialize(inherited_context : SpanContext)
        @trace_id = inherited_context.trace_id
        @trace_state = inherited_context.trace_state
        @trace_flags = inherited_context.trace_flags
        @remote = inherited_context.remote
        @span_id = IdGenerator.span_id
      end
    end
  end
end

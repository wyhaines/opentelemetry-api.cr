require "./../text_map_propagator"
require "./trace_context/trace_parent"
require "./text_map_setter"
require "./text_map_getter"

module OpenTelemetry
  module Propagation
    class TraceContext < TextMapPropagator
      property trace_parent : TraceParent = TraceParent.new
      property context : Context?

      TRACEPARENT_KEY = "traceparent"
      TRACESTATE_KEY = "tracestate"
      FIELDS = {"traceparent", "tracestate"}

      def initialize
      end

      def initialize(trace_parent : TraceParent, context : Context? = nil)
        @trace_parent = trace_parent
        @context = context
      end

      def inject(carrier, context : Context, setter : TextMapSetter.class = TextMapSetter)
        span = OpenTelemetry.current_span
        if span
          span_context = span.context

          setter.set(carrier, TRACEPARENT_KEY, TraceParent.from_span_contex(span_context).to_s)
          setter.set(carrier, TRACESTATE_KEY, tracestate)
        end
      end

      def extract
      end

      def fields
        FIELDS
      end

      def version
        trace_parent.version
      end

      def version=(value : Slice(UInt8))
        trace_parent.version = value
        @trace_parent = self.trace_parent
      end

      def version=(value)
        self.version = value.hexbytes
      end

      def trace_id
        trace_parent.trace_id
      end

      def trace_id=(value : Slice(UInt8))
        trace_parent.trace_id = value
        @trace_parent = self.trace_parent
      end

      def trace_id=(value)
        self.trace_id = value.hexbytes
      end

      def span_id
        trace_parent.span_id
      end

      def span_id=(value : Slice(UInt8))
        trace_parent.span_id = value
        @trace_parent = self.trace_parent
      end

      def span_id=(value)
        self.span_id = value.hexbytes
      end

      def trace_flags
        trace_parent.trace_flags.value
      end

      def trace_flags=(value : Slice(UInt8))
        self.trace_flags = value.hexstring.to_i(16)
      end

      def trace_flags=(value : String)
        self.trace_flags = value.to_i(16)
      end

      def trace_flags=(value)
        trace_parent.trace_flags = TraceFlags.new(value)
        @trace_parent = self.trace_parent
      end

      def traceparent
        trace_parent.to_s
      end

      def traceparent(io)
        trace_parent.to_s(io)
      end

      def tracestate
        @context.map do |key, value|
          "#{key}=#{value}"
        end.join(",")
      end
    end
  end
end

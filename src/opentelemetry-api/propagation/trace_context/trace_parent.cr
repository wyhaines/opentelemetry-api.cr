module OpenTelemetry
  module Propagation
    class TraceContext < TextMapPropagator
      struct TraceParent
        class InvalidFormatError < ArgumentError
          def initialize(format)
            super("Invalid TraceParent Format: #{format} lacks a recognizeable version, trace id, span id, or trace flags.")
          end
        end

        class InvalidVersionError < ArgumentError
          def initialize(version)
            super("Invalid TraceParent Version: #{version} is not a valid version.")
          end
        end

        class InvalidTraceIdError < ArgumentError
          def initialize(trace_id)
            super("Invalid TraceParent TraceId: #{trace_id} is not a valid trace id.")
          end
        end

        class InvalidSpanIdError < ArgumentError
          def initialize(span_id)
            super("Invalid TraceParent SpanId: #{span_id} is not a valid span id.")
          end
        end

        class InvalidTraceFlagsIdError < ArgumentError
          def initialize(trace_flags)
            super("Invalid TraceParent TraceFlags: #{trace_flags} is not a valid trace flags.")
          end
        end

        property version : Bytes
        property trace_id : Bytes
        property span_id : Bytes
        property trace_flags : TraceFlags

        VERSION_MATCH = /(?<version>[A-Fa-f0-9]{2})/
        MATCH         = /^(?<version>[A-Fa-f0-9]{2})-(?<trace_id>[A-Fa-f0-9]{32})-(?<span_id>[A-Fa-f0-9]{16})-(?<flags>[A-Fa-f0-9]{2})(?<ignored>-.*)?$/

        def self.from_span_context(ctx : SpanContext)
          new(
            trace_id: ctx.trace_id,
            span_id: ctx.span_id,
            trace_flags: ctx.trace_flags
          )
        end

        def initialize
          initialize(
            Slice(UInt8).new(1, 0),
            Slice(UInt8).new(16, 0),
            Slice(UInt8).new(8, 0),
            Slice(UInt8).new(1, 0))
        end

        def self.from_string(traceparent : String)
          new(traceparent.split(/-/, 4))
        end

        def initialize(parts : Array(String))
          initialize(parts[0], parts[1], parts[2], parts[3])
        end

        def initialize(trace_id, span_id, trace_flags)
          initialize(Slice(UInt8).new(1, 0), trace_id, span_id, trace_flags)
        end

        def initialize(version, trace_id, span_id, trace_flags)
          if version.is_a?(Slice(UInt8))
          elsif version.is_a?(Int)
            version = version.to_s(16).hexbytes
          else
            version = version.hexbytes
          end
          if trace_id.is_a?(Slice(UInt8))
          else
            trace_id = trace_id.hexbytes
          end
          if span_id.is_a?(Slice(UInt8))
          else
            span_id = span_id.hexbytes
          end
          if trace_flags.is_a?(Slice(UInt8))
            trace_flags = TraceFlags.new(trace_flags.hexstring.to_i(16))
          elsif trace_flags.is_a?(Int)
            trace_flags = TraceFlags.new(trace_flags)
          elsif trace_flags.is_a?(TraceFlags)
            trace_flags
          else
            trace_flags = TraceFlags.new(trace_flags.to_i(16))
          end

          validate(version, trace_id, span_id, trace_flags)

          @version = version
          @trace_id = trace_id
          @span_id = span_id
          @trace_flags = trace_flags
        end

        private def validate(version, trace_id, span_id, trace_flags)
          raise InvalidVersionError.new(version) unless version.hexstring =~ VERSION_MATCH
          raise InvalidTraceIdError.new(trace_id) unless trace_id.hexstring =~ Trace::MATCH
          raise InvalidSpanIdError.new(span_id) unless span_id.hexstring =~ Span::MATCH
        end

        def self.valid?(traceparent : String)
          MATCH.match(traceparent)
        end

        def valid?
          MATCH.match(to_s)
        end

        def to_s(io)
          io << "#{@version.hexstring.lpad(2, '0')}-#{@trace_id.hexstring.lpad(32, '0')}-#{@span_id.hexstring.lpad(16, '0')}-#{@trace_flags.value.to_s.lpad(2, '0')}"
        end
      end
    end
  end
end

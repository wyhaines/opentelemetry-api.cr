module OpenTelemetry
  struct Sampler
    struct SamplingResult
      enum Decision
        Drop
        RecordOnly
        RecordAndSample
      end

      getter decision : Decision
      getter attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
      getter trace_state : Hash(String, String) = {} of String => String

      def initialize(
        @decision,
        attributes = {} of String => AnyAttribute,
        trace_state = {} of String => String
      )
        @attributes.merge! attributes
        @trace_state.merge! trace_state
      end
    end
  end
end

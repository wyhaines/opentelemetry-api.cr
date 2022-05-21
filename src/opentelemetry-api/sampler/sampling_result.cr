module OpenTelemetry
  struct Sampler::SamplingResult
    enum Decision
      Drop
      RecordOnly
      RecordAndSample
    end

    getter decision : Decision
    @sampler : Sampler
    getter attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
    getter trace_state : Hash(String, String) = {} of String => String
    getter description : String

    def initialize(
      @decision,
      @sampler,
      attributes = {} of String => AnyAttribute,
      trace_state = {} of String => String
    )
      @attributes.merge! attributes
      @trace_state.merge! trace_state
      @description = @sampler.description
    end
  end
end

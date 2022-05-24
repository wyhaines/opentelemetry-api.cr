module OpenTelemetry
  struct Sampler::AlwaysRecord < InheritableSampler
    def initialize(arg = nil)
    end

    private def should_sample_impl(context, name, trace_id, kind, attributes, links) : SamplingResult
      SamplingResult.new(SamplingResult::Decision::RecordOnly)
    end

    # The AlwaysOn sample does not respond to configuration. Thus, the description is never anyting but a plain label.
    def description
      "AlwaysOn"
    end
  end
end

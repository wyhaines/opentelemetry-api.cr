module OpenTelemetry
  struct Sampler::AlwaysOn < Sampler
    private def should_sample_impl(context, name, trace_id, kind, attributes, links) : SamplingResult
      SamplingResult.new(SamplingResult::Decision::RecordAndSample, self)
    end
  end
end

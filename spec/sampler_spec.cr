require "./spec_helper"

describe OpenTelemetry::Sampler::AlwaysOn do
  it "has the correct description" do
    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x01)
    context = OpenTelemetry::SpanContext.build do |ctx|
      ctx.remote = false
      ctx.trace_id = trace_id
      ctx.span_id = span_id
      ctx.trace_flags = trace_flags
    end
    sampler = OpenTelemetry::Sampler::AlwaysOn.new

    result = sampler.should_sample(context, "foo")
    result.decision.should eq OpenTelemetry::Sampler::SamplingResult::Decision::RecordAndSample
    result.description.should eq "AlwaysOn"
  end
end
require "./spec_helper"

describe OpenTelemetry::Sampler::AlwaysOn do
  it "has the correct description and decision" do
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
    sampler.description.should eq "AlwaysOn"
  end
end

describe OpenTelemetry::Sampler::AlwaysOff do
  it "has the correct description and decision" do
    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x01)
    context = OpenTelemetry::SpanContext.build do |ctx|
      ctx.remote = false
      ctx.trace_id = trace_id
      ctx.span_id = span_id
      ctx.trace_flags = trace_flags
    end
    sampler = OpenTelemetry::Sampler::AlwaysOff.new

    result = sampler.should_sample(context, "foo")
    result.decision.should eq OpenTelemetry::Sampler::SamplingResult::Decision::Drop
    sampler.description.should eq "AlwaysOff"
  end
end

describe OpenTelemetry::Sampler::TraceIdRatioBased do
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
    sampler = OpenTelemetry::Sampler::TraceIdRatioBased.new(0.5)
    sampler.description.should eq "TraceIdRatioBased{0.5}"

    sampler = OpenTelemetry::Sampler::TraceIdRatioBased.new(1, 4)
    sampler.description.should eq "TraceIdRatioBased{0.25}"
  end

  it "delivers the correct ratio of decisions" do
    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x01)
    context = OpenTelemetry::SpanContext.build do |ctx|
      ctx.remote = false
      ctx.trace_id = trace_id
      ctx.span_id = span_id
      ctx.trace_flags = trace_flags
    end
    sampler = OpenTelemetry::Sampler::TraceIdRatioBased.new(0.5)

    count = 0
    100000.times do
      trace_id = OpenTelemetry::IdGenerator.trace_id
      span_id = OpenTelemetry::IdGenerator.span_id
      trace_flags = OpenTelemetry::TraceFlags.new(0x01)
      context = OpenTelemetry::SpanContext.build do |ctx|
        ctx.remote = false
        ctx.trace_id = trace_id
        ctx.span_id = span_id
        ctx.trace_flags = trace_flags
      end

      result = sampler.should_sample(context)
      count += 1 if result.decision == OpenTelemetry::Sampler::SamplingResult::Decision::RecordAndSample
    end

    count.should be_close(50000, 1000)

    count = 0
    sampler = OpenTelemetry::Sampler::TraceIdRatioBased.new(1,11)
    100000.times do
      trace_id = OpenTelemetry::IdGenerator.trace_id
      span_id = OpenTelemetry::IdGenerator.span_id
      trace_flags = OpenTelemetry::TraceFlags.new(0x01)
      context = OpenTelemetry::SpanContext.build do |ctx|
        ctx.remote = false
        ctx.trace_id = trace_id
        ctx.span_id = span_id
        ctx.trace_flags = trace_flags
      end

      result = sampler.should_sample(context)
      count += 1 if result.decision == OpenTelemetry::Sampler::SamplingResult::Decision::RecordAndSample
    end

    count.should be_close(9091, 300)
  end
end

describe OpenTelemetry::Sampler::ParentBased do
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
    sampler = OpenTelemetry::Sampler::ParentBased.new(OpenTelemetry::Sampler::AlwaysOn.new)
    sampler.description.should eq "ParentBased{root=AlwaysOn, remote_parent_sampled=AlwaysOn, remote_parent_not_sampled=AlwaysOff, local_parent_sampled=AlwaysOn, local_parent_not_sampled=OpenTelemetry::Sampler::AlwaysOff()}"
  end

  it "makes the right decisions" do
    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x01)
    context = OpenTelemetry::SpanContext.build do |ctx|
      ctx.remote = false
      ctx.trace_id = trace_id
      ctx.span_id = span_id
      ctx.trace_flags = trace_flags
    end
    result = OpenTelemetry::Sampler::ParentBased.new(OpenTelemetry::Sampler::AlwaysOn.new).should_sample(context)
    result.decision.should eq OpenTelemetry::Sampler::SamplingResult::Decision::RecordAndSample

    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x01)
    context = OpenTelemetry::SpanContext.build do |ctx|
      ctx.remote = true
      ctx.trace_id = trace_id
      ctx.span_id = span_id
      ctx.trace_flags = trace_flags
    end
    result = OpenTelemetry::Sampler::ParentBased.new(OpenTelemetry::Sampler::AlwaysOn.new).should_sample(context)
    result.decision.should eq OpenTelemetry::Sampler::SamplingResult::Decision::RecordAndSample

    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x00)
    context = OpenTelemetry::SpanContext.build do |ctx|
      ctx.remote = true
      ctx.trace_id = trace_id
      ctx.span_id = span_id
      ctx.trace_flags = trace_flags
    end
    result = OpenTelemetry::Sampler::ParentBased.new(OpenTelemetry::Sampler::AlwaysOn.new).should_sample(context)
    result.decision.should eq OpenTelemetry::Sampler::SamplingResult::Decision::Drop

    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x01)
    context = OpenTelemetry::SpanContext.build do |ctx|
      ctx.remote = false
      ctx.trace_id = trace_id
      ctx.span_id = span_id
      ctx.trace_flags = trace_flags
    end
    result = OpenTelemetry::Sampler::ParentBased.new(OpenTelemetry::Sampler::AlwaysOn.new).should_sample(context)
    result.decision.should eq OpenTelemetry::Sampler::SamplingResult::Decision::RecordAndSample

    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x00)
    context = OpenTelemetry::SpanContext.build do |ctx|
      ctx.remote = false
      ctx.trace_id = trace_id
      ctx.span_id = span_id
      ctx.trace_flags = trace_flags
    end
    result = OpenTelemetry::Sampler::ParentBased.new(OpenTelemetry::Sampler::AlwaysOn.new).should_sample(context)
    result.decision.should eq OpenTelemetry::Sampler::SamplingResult::Decision::Drop
  end
end
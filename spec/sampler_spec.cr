require "./spec_helper"

describe OpenTelemetry::Sampler::AlwaysOn, tags: ["Sampler", "SamplerAlwaysOn"] do
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

describe OpenTelemetry::Sampler::AlwaysOff, tags: ["Sampler", "SampleAlwaysOff"] do
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

describe OpenTelemetry::Sampler::TraceIdRatioBased, tags: ["Sampler", "TraceIdRatioBased"] do
  it "has the correct description" do
    OpenTelemetry::Sampler::TraceIdRatioBased.new(0.5).description
      .should eq "TraceIdRatioBased{0.5}"

    OpenTelemetry::Sampler::TraceIdRatioBased.new(1, 4).description
      .should eq "TraceIdRatioBased{0.25}"

    OpenTelemetry::Sampler::TraceIdRatioBased.new("0.153").description
      .should eq "TraceIdRatioBased{0.153}"
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
    sampler = OpenTelemetry::Sampler::TraceIdRatioBased.new(1, 11)
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

  it "gets the correct ratio of spans when generating actual traces" do
    checkout_config do
      memory = IO::Memory.new

      OpenTelemetry.configure do |config|
        config.exporter = OpenTelemetry::Exporter.new(variant: :io, io: memory)
        config.sampler = OpenTelemetry::Sampler::TraceIdRatioBased.new(0.5)
      end

      1000.times do
        trace = OpenTelemetry.trace
        trace.in_span("IO Memory Exporter Test") do |span|
          span.set_attribute("key", "value")
        end
      end

      _, server_traces = FindJson.from_io(memory)
      server_traces.size.should be_close(500, 65)
    end
  end
end

describe OpenTelemetry::Sampler::ParentBased, tags: ["Sampler", "ParentBased"] do
  it "has the correct description" do
    sampler = OpenTelemetry::Sampler::ParentBased.new(OpenTelemetry::Sampler::AlwaysOn.new)
    sampler.description.should eq "ParentBased{root=AlwaysOn, remote_parent_sampled=AlwaysOn, remote_parent_not_sampled=AlwaysOff, local_parent_sampled=AlwaysOn, local_parent_not_sampled=AlwaysOff}"
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

describe OpenTelemetry::Sampler, tags: ["Sampler"] do
  it "can setup samplers via environment variables" do
    checkout_config do
      memory = IO::Memory.new

      ENV["OTEL_TRACES_SAMPLER"] = "alwayson"
      OpenTelemetry.configure do |config|
        config.exporter = OpenTelemetry::Exporter.new(variant: :io, io: memory)
      end
      OpenTelemetry.trace_provider.config.sampler.should be_a(OpenTelemetry::Sampler::AlwaysOn)

      ENV["OTEL_TRACES_SAMPLER"] = "always_off"
      OpenTelemetry.configure do |config|
        config.exporter = OpenTelemetry::Exporter.new(variant: :io, io: memory)
      end
      OpenTelemetry.trace_provider.config.sampler.should be_a(OpenTelemetry::Sampler::AlwaysOff)

      ENV["OTEL_TRACES_SAMPLER"] = "traceidratio"
      OpenTelemetry.configure do |config|
        config.exporter = OpenTelemetry::Exporter.new(variant: :io, io: memory)
      end
      OpenTelemetry.trace_provider.config.sampler.should be_a(OpenTelemetry::Sampler::TraceIdRatioBased)
      OpenTelemetry.trace_provider.config.sampler.description.should eq "TraceIdRatioBased{0.0}"

      ENV["OTEL_TRACES_SAMPLER_ARG"] = "0.5"
      OpenTelemetry.configure do |config|
        config.exporter = OpenTelemetry::Exporter.new(variant: :io, io: memory)
      end
      OpenTelemetry.trace_provider.config.sampler.should be_a(OpenTelemetry::Sampler::TraceIdRatioBased)
      OpenTelemetry.trace_provider.config.sampler.description.should eq "TraceIdRatioBased{0.5}"
      ENV.delete("OTEL_TRACES_SAMPLER_ARG")

      ENV["OTEL_TRACES_SAMPLER"] = "parentbased_always_off"
      OpenTelemetry.configure do |config|
        config.exporter = OpenTelemetry::Exporter.new(variant: :io, io: memory)
      end
      OpenTelemetry.trace_provider.config.sampler.should be_a(OpenTelemetry::Sampler::ParentBased)
      OpenTelemetry.trace_provider.config.sampler.description.should eq "ParentBased{root=AlwaysOff, remote_parent_sampled=AlwaysOn, remote_parent_not_sampled=AlwaysOff, local_parent_sampled=AlwaysOn, local_parent_not_sampled=AlwaysOff}"

      ENV["OTEL_TRACES_SAMPLER"] = "parentbased_traceidratio"
      ENV["OTEL_TRACES_SAMPLER_ARG"] = "0.5"
      OpenTelemetry.configure do |config|
        config.exporter = OpenTelemetry::Exporter.new(variant: :io, io: memory)
      end
      OpenTelemetry.trace_provider.config.sampler.should be_a(OpenTelemetry::Sampler::ParentBased)
      OpenTelemetry.trace_provider.config.sampler.description.should eq "ParentBased{root=TraceIdRatioBased{0.5}, remote_parent_sampled=AlwaysOn, remote_parent_not_sampled=AlwaysOff, local_parent_sampled=AlwaysOn, local_parent_not_sampled=AlwaysOff}"

      1000.times do
        trace = OpenTelemetry.trace
        trace.in_span("IO Memory Exporter Test") do |span|
          span.set_attribute("key", "value")
        end
      end

      _, server_traces = FindJson.from_io(memory)
      server_traces.size.should be_close(500, 60)

      ENV.delete("OTEL_TRACES_SAMPLER")
      ENV.delete("OTEL_TRACES_SAMPLER_ARG")
    end
  end
end

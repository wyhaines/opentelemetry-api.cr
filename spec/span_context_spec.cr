require "./spec_helper"

describe OpenTelemetry::SpanContext do
  it "can create a simple SpanContext" do
    context = OpenTelemetry::SpanContext.new

    context.remote.should be_false
    context.trace_id.should eq Bytes.new(16, 0)
    context.span_id.should eq Bytes.new(8, 0)
    context.trace_state.empty?.should be_true
    context.trace_flags.should eq OpenTelemetry::TraceFlags::None
  end

  it "can create a SpanContext with specified values" do
    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x01)
    context = OpenTelemetry::SpanContext.new(
      remote: false,
      trace_id: trace_id,
      span_id: span_id,
      parent_id: nil,
      trace_flags: trace_flags,
      trace_state: {"key" => "value"}
    )

    context.remote.should be_false
    context.trace_id.should eq trace_id
    context.span_id.should eq span_id
    context.trace_state.should eq({"key" => "value"})
    context.trace_flags.should eq trace_flags
  end

  it "can create a SpanContext using the block syntax" do
    trace_id = OpenTelemetry::IdGenerator.trace_id
    span_id = OpenTelemetry::IdGenerator.span_id
    trace_flags = OpenTelemetry::TraceFlags.new(0x01)
    context = OpenTelemetry::SpanContext.build do |ctx|
      ctx.remote = false
      ctx.trace_id = trace_id
      ctx.span_id = span_id
      ctx.trace_flags = trace_flags
      ctx.trace_state = {"key" => "value"}
    end

    context.remote.should be_false
    context.trace_id.should eq trace_id
    context.span_id.should eq span_id
    context.trace_state.should eq({"key" => "value"})
    context.trace_flags.should eq trace_flags
  end
end

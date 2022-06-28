require "./spec_helper"

describe OpenTelemetry::API::SpanContext::Config do
  it "defines #initialize" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.@trace_flags.value.should eq 0x00
    config.@trace_id.should eq Slice(UInt8).new(16)
    config.@span_id.should eq Slice(UInt8).new(8)
    config.@parent_id.should be_nil

    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8),
      Slice(UInt8).new(8))
    config.@trace_id.should eq Slice(UInt8).new(16)
    config.@span_id.should eq Slice(UInt8).new(8)
    config.@parent_id.should eq Slice(UInt8).new(8)

    sctx = OpenTelemetry::API::SpanContext.new
    config = OpenTelemetry::API::SpanContext::Config.new(sctx)
    config.@trace_flags.value.should eq 0x00
    config.@trace_id.should eq Slice(UInt8).new(16)
    config.@span_id.should eq Slice(UInt8).new(8)
  end

  it "defines #trace_id" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.trace_id.should eq Slice(UInt8).new(16)
  end

  it "defines #trace_id=" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.trace_id = Slice(UInt8).new(16, 1)
    config.trace_id.should eq Slice(UInt8).new(16, 1)
  end

  it "defines #span_id" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.span_id.should eq Slice(UInt8).new(8)
  end

  it "defines #span_id=" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.span_id = Slice(UInt8).new(8, 1)
    config.span_id.should eq Slice(UInt8).new(8, 1)
  end

  it "defines #parent_id" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.parent_id.should be_nil
  end

  it "defines #parent_id=" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.parent_id = Slice(UInt8).new(8, 1)
    config.parent_id.should eq Slice(UInt8).new(8, 1)
  end

  it "defines #trace_flags" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.trace_flags.value.should eq 0x00
  end

  it "defines #trace_flags=" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.trace_flags = OpenTelemetry::API::TraceFlags.new(0x01)
    config.trace_flags.value.should eq 0x01
  end

  it "defines #trace_state" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.trace_state.empty?.should eq true
    config.trace_state["key"] = "value"
    config.trace_state["key2"] = "value2"
    config.trace_state["key"].should eq "value"
    config.trace_state["key2"].should eq "value2"
  end

  it "defines #trace_state=" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.trace_state = {"key" => "value"}
    config.trace_state.should eq({"key" => "value"})
  end

  it "defines #remote" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.remote.should be_false
  end

  it "defines #remote=" do
    config = OpenTelemetry::API::SpanContext::Config.new(
      Slice(UInt8).new(16),
      Slice(UInt8).new(8))
    config.remote = true
    config.remote.should be_true
  end
end

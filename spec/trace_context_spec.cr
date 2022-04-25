require "./spec_helper"

describe OpenTelemetry::Propagation::TraceContext do
  it "the TraceParent can encapsulate parent state in all of its guises" do
    trace_parent_string = "01-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
    parent = OpenTelemetry::Propagation::TraceContext::TraceParent.from_string(trace_parent_string)
    parent.version.hexstring.should eq "01"
    parent.trace_id.hexstring.should eq "4bf92f3577b34da6a3ce929d0e0e4736"
    parent.span_id.hexstring.should eq "00f067aa0ba902b7"
    parent.trace_flags.value.should eq 0x01
    parent.to_s.should eq trace_parent_string
  end

  it "can create a TraceContext with default values" do
    trace_context = OpenTelemetry::Propagation::TraceContext.new
    trace_context.version.hexstring.should eq "00"
    trace_context.trace_id.hexstring.should eq "00000000000000000000000000000000"
    trace_context.span_id.hexstring.should eq "0000000000000000"
    trace_context.trace_flags.should eq 0x00
  end

  it "can set create a TraceContext with a pre-existing TraceParent" do
    parent = OpenTelemetry::Propagation::TraceContext::TraceParent.from_string("01-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01")
    trace_context = OpenTelemetry::Propagation::TraceContext.new(parent)
    trace_context.version.hexstring.should eq "01"
    trace_context.trace_id.hexstring.should eq "4bf92f3577b34da6a3ce929d0e0e4736"
    trace_context.span_id.hexstring.should eq "00f067aa0ba902b7"
    trace_context.trace_flags.should eq 0x01
  end

  it "can set TraceParent attributes through the TraceContext" do
    trace_context = OpenTelemetry::Propagation::TraceContext.new
    trace_context.version = "01"
    trace_context.trace_id = "4bf92f3577b34da6a3ce929d0e0e4736"
    trace_context.span_id = "00f067aa0ba902b7"
    trace_context.trace_flags = "01"
    trace_context.version.hexstring.should eq "01"
    trace_context.trace_id.hexstring.should eq "4bf92f3577b34da6a3ce929d0e0e4736"
    trace_context.span_id.hexstring.should eq "00f067aa0ba902b7"
    trace_context.trace_flags.should eq 0x01
  end
end

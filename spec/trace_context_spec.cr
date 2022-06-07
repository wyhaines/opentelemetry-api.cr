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

  describe "#extract" do
    it "skips extract trace context if missing HTTP::Header" do
      headers = HTTP::Headers{
        "Accept"     => "*/*",
        "Host"       => "127.0.0.1:8080",
        "User-Agent" => "curl/7.79.1",
      }
      subject = OpenTelemetry::Propagation::TraceContext.new.extract(headers)
      subject.should be_nil
    end
  end

  it "can inject TraceContext into an object such as HTTP::Headers" do
    provider = OpenTelemetry::TraceProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::Exporter.new)
    trace = provider.trace do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end

    trace.in_span("request") do |span|
      span.set_attribute("verb", "GET")
      span.set_attribute("url", "http://example.com/foo")
      span.add_event("dispatching to handler")
      span["fib"] = "far"
      span["flo"] = "fling"

      OpenTelemetry::Context["foo"] = "bar"
      OpenTelemetry::Context["baz"] = "qux"
      trace.in_span("test TraceContext Injection") do |_other_span|
        headers = HTTP::Headers{
          "X-B3-TraceId"      => "4bf92f3577b34da6a3ce929d0e0e4736",
          "X-B3-SpanId"       => "00f067aa0ba902b7",
          "X-B3-ParentSpanId" => "00f067aa0ba902b7",
          "X-B3-Sampled"      => "1",
          "X-B3-Flags"        => "1",
          "X-Foo"             => "bar",
          "X-Baz"             => "qux",
        }

        new_span_context = OpenTelemetry::Propagation::TraceContext.new(span.context).inject(headers)
        new_span_context.is_a?(OpenTelemetry::SpanContext).should be_true
        headers["X-B3-TraceID"].should eq "4bf92f3577b34da6a3ce929d0e0e4736"
        headers["X-Baz"].should eq "qux"
        headers["tracestate"].should match /baz=qux,foo=bar/
        OpenTelemetry::Propagation::TraceContext::TraceParent.valid?(headers["traceparent"]).should be_truthy

        headers = HTTP::Headers{
          "X-B3-TraceId"      => "4bf92f3577b34da6a3ce929d0e0e4736",
          "X-B3-SpanId"       => "00f067aa0ba902b7",
          "X-B3-ParentSpanId" => "00f067aa0ba902b7",
          "X-B3-Sampled"      => "1",
          "X-B3-Flags"        => "1",
          "X-Foo"             => "bar",
          "X-Baz"             => "qux",
        }
        new_context = OpenTelemetry::Propagation::TraceContext.new(span.context).inject(headers, OpenTelemetry::Context.current)
        new_context.is_a?(OpenTelemetry::Context).should be_true
        headers["X-B3-TraceID"].should eq "4bf92f3577b34da6a3ce929d0e0e4736"
        headers["X-Baz"].should eq "qux"
        headers["tracestate"].should match /baz=qux,foo=bar/
        OpenTelemetry::Propagation::TraceContext::TraceParent.valid?(headers["traceparent"]).should be_truthy
      end
    end
  end
end

require "./spec_helper"

describe OpenTelemetry::Tracer do
  it "has an id" do
    provider = OpenTelemetry::TracerProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::NullExporter.new)
    tracer = provider.tracer do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end

    tracer.id.hexstring.should_not eq Slice(UInt8).new(8,0).hexstring
    tracer.id.should eq tracer.trace_id

    tracer.id.should_not eq (provider.tracer do |t|
      t.service_name = "my_app_or_library"
      t.service_version = "1.1.1"
    end.id)
  end

  it "can reate a span" do
    provider = OpenTelemetry::TracerProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::NullExporter.new)
    tracer = provider.tracer do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end
    tracer.in_span("request") do |span|
      span.set_attribute("verb", "GET")
      span.set_attribute("url", "http://example.com/foo")
      span.add_event("dispatching to handler")
    end
  end

  it "has an accessible span stack" do
    provider = OpenTelemetry::TracerProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::NullExporter.new)
    tracer = provider.tracer do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end

    tracer.span_stack.size.should eq 0
    tracer.in_span("request") do |span|
      span.set_attribute("verb", "GET")
      span.set_attribute("url", "http://example.com/foo")
      span.add_event("dispatching to handler")
      tracer.span_stack.size.should eq 1
      tracer.span_stack[0].attributes.has_key?("verb").should be_true
      tracer.span_stack[0].attributes.has_key?("url").should be_true
      tracer.span_stack[0].attributes["verb"].value.should eq "GET"
    end
  end

  it "has an accessible root span" do
    provider = OpenTelemetry::TracerProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::NullExporter.new)
    tracer = provider.tracer do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end
    tracer.root_span.should be_nil
    tracer.in_span("request") do |span|
      span.set_attribute("verb", "GET")
      span.set_attribute("url", "http://example.com/foo")
      span.add_event("dispatching to handler")
      tracer.root_span.should_not be_nil
      tracer.root_span.should eq tracer.span_stack[0]
    end
  end

end

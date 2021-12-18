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

    tracer.id.hexstring.should_not eq Slice(UInt8).new(8, 0).hexstring
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

  it "produces traces and spans with the expected ids" do
    provider = OpenTelemetry::TracerProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::NullExporter.new)
    tracer = provider.tracer do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end

    tracer.id.hexstring.should_not be_empty
    tracer.id.size.should eq 16
    tracer.id.hexstring.should_not eq "0000000000000000"

    tracer.in_span("request") do |span|
      span.id.hexstring.should_not be_empty
      span.id.hexstring.should_not eq "00000000"

      span.set_attribute("verb", "GET")
      span.set_attribute("url", "http://example.com/foo")
      sleep(rand/1000)
      span.add_event("dispatching to handler")
      tracer.in_span("handler") do |child_span|
        child_span.id.should_not eq span.id
        sleep(rand/1000)
        child_span.add_event("dispatching to database")
        tracer.in_span("db") do |db_span|
          db_span.add_event("querying database")
          sleep(rand/1000)
        end
        tracer.in_span("external api") do |api_span|
          api_span.add_event("querying api")
          sleep(rand/1000)
        end
        sleep(rand/1000)
      end
    end
  end
end

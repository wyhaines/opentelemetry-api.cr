require "./spec_helper"

describe OpenTelemetry::Trace do
  it "has an id" do
    provider = OpenTelemetry::TraceProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::Exporter::Null.new)
    trace = provider.trace do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end

    trace.id.hexstring.should_not eq Slice(UInt8).new(8, 0).hexstring
    trace.id.should eq trace.trace_id

    trace.id.should_not eq (provider.trace do |t|
      t.service_name = "my_app_or_library"
      t.service_version = "1.1.1"
    end.id)
  end

  it "can reate a span" do
    provider = OpenTelemetry::TraceProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::Exporter::Null.new)
    trace = provider.trace do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end
    trace.in_span("request") do |span|
      span.set_attribute("verb", "GET")
      span.set_attribute("url", "http://example.com/foo")
      span.add_event("dispatching to handler")
    end
  end

  it "has an accessible span stack" do
    provider = OpenTelemetry::TraceProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::Exporter::Null.new)
    trace = provider.trace do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end

    trace.span_stack.size.should eq 0
    trace.in_span("request") do |span|
      span.set_attribute("verb", "GET")
      span.set_attribute("url", "http://example.com/foo")
      span.add_event("dispatching to handler")
      trace.span_stack.size.should eq 1
      trace.span_stack[0].attributes.has_key?("verb").should be_true
      trace.span_stack[0].attributes.has_key?("url").should be_true
      trace.span_stack[0].attributes["verb"].value.should eq "GET"
    end
  end

  it "has an accessible root span" do
    provider = OpenTelemetry::TraceProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::Exporter::Null.new)
    trace = provider.trace do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end
    trace.root_span.should be_nil
    trace.in_span("request") do |span|
      span.set_attribute("verb", "GET")
      span.set_attribute("url", "http://example.com/foo")
      span.add_event("dispatching to handler")
      trace.root_span.should_not be_nil
      trace.root_span.should eq trace.span_stack[0]
    end
  end

  it "produces traces and spans with the expected ids" do
    provider = OpenTelemetry::TraceProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::Exporter::Null.new)
    trace = provider.trace do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end

    trace.id.hexstring.should_not be_empty
    trace.id.size.should eq 16
    trace.id.hexstring.should_not eq "0000000000000000"

    trace.in_span("request") do |span|
      span.id.hexstring.should_not be_empty
      span.id.hexstring.should_not eq "00000000"

      span.set_attribute("verb", "GET")
      span.set_attribute("url", "http://example.com/foo")
      sleep(rand/1000)
      span.add_event("dispatching to handler")
      trace.in_span("handler") do |child_span|
        child_span.id.should_not eq span.id
        sleep(rand/1000)
        child_span.add_event("dispatching to database")
        trace.in_span("db") do |db_span|
          db_span.id.should_not eq span.id
          db_span.id.should_not eq child_span.id
          db_span.add_event("querying database")
          sleep(rand/1000)
        end
        trace.in_span("external api") do |api_span|
          api_span.id.should_not eq span.id
          api_span.id.should_not eq child_span.id
          api_span.add_event("querying api")
          sleep(rand/1000)
        end
        sleep(rand/1000)
      end
    end
  end
end

require "./spec_helper"

describe OpenTelemetry do
  before_each do
    # Ensure that global state is always reset to a known starting point
    # before each spec runs.
    OpenTelemetry.configure do |config|
      config.service_name = "my_app_or_library"
      config.service_version = "1.1.1"
      config.exporter = TestExporter.new
    end
  end

  it "default configuration is setup as expected" do
    OpenTelemetry.config.service_name.should eq "my_app_or_library"
    OpenTelemetry.config.service_version.should eq "1.1.1"
    OpenTelemetry.config.exporter.should be_a TestExporter
  end

  it "can create a tracer with arguments passed to the class method" do
    tracer = OpenTelemetry.tracer_provider(
      "my_app_or_library",
      "1.2.3",
      OpenTelemetry::NullExporter.new)

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "1.2.3"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "substitutes the global provider configuration when values are not provided via method argument initialization" do
    tracer = OpenTelemetry.tracer_provider("my_app_or_library2")
    tracer.service_name.should eq "my_app_or_library2"
    tracer.service_version.should eq "1.1.1"
    tracer.exporter.should be_a TestExporter
  end

  it "can create a tracer via a block passed to the class method" do
    tracer = OpenTelemetry.tracer_provider do |t|
      t.service_name = "my_app_or_library"
      t.service_version = "1.2.3"
      t.exporter = OpenTelemetry::NullExporter.new
    end

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "1.2.3"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "substitutes the global provider configuration when values are not set via block initialization" do
    tracer = OpenTelemetry.tracer_provider do |t|
      t.service_version = "2.2.2"
    end

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "2.2.2"
    tracer.exporter.should be_a TestExporter
  end

  it "can create a span and set/get attributes on that span" do
    span = OpenTelemetry::Span.new
    verb = "GET"
    url = "http://example.com/foo"
    span.set_attribute("verb", verb)
    span["url"] = url
    span["verb"].should eq verb
    span["url"].should eq url
    span.get_attribute("url").value.should eq url
    span["bools"] = true
    span["bools"] = false
    span["bools"].should be_false
    span.get_attribute("bools") << true
    span["bools"].should eq [false, true]
    span["headers"] = Array(String).new
    span.get_attribute("headers") << "Content-Type: text/plain"
    span.get_attribute("headers") << "Content-Length: 23"
    span["headers"].should eq ["Content-Type: text/plain", "Content-Length: 23"]
  end

  it "can set events on a span" do
    span = OpenTelemetry::Span.new
    span.set_attribute("verb", "GET")
    span.set_attribute("url", "http://example.com/foo")
    span.add_event("dispatching to handler") do |e|
      e["verb"] = "GET"
      e["url"] = "http://example.com/foo"
    end
    error_time = Time.utc.to_s
    span.add_event("error") do |e|
      e["error"] = "error"
      e["time"] = error_time
      e["message"] = "There was a really bad error."
    end
    span.events.size.should eq 2
    e = span.events.first
    e.name.should eq "dispatching to handler"
    e.attributes["verb"].value.should eq "GET"
    e.attributes["url"].value.should eq "http://example.com/foo"
    e = span.events.last
    e.name.should eq "error"
    e.attributes["error"].value.should eq "error"
    e.attributes["time"].value.should eq error_time
    e.attributes["message"].value.should eq "There was a really bad error."
  end

  it "can use a tracer to create a span" do
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

  it "can create nested spans" do
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
      sleep(rand/1000)
      span.add_event("dispatching to handler")
      tracer.in_span("handler") do |child_span|
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

    buffer = iterate_span_nodes tracer.root_span, 0, [] of String
    buffer.should eq ["request", "  handler", "    db", "    external api"]
  end
end

def iterate_span_nodes(span, indent, buffer)
  return if span.nil?

  buffer << "#{" " * indent}#{span.name}"
  if span && span.children
    span.children.each do |child|
      iterate_span_nodes(child, indent + 2, buffer)
    end
  end

  buffer
end

require "./spec_helper"

describe OpenTelemetry::Span do
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
    span.id.should_not be_nil
    span.id.should eq span.context.span_id
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

  it "can use a trace to create a span" do
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

  it "can create nested spans" do
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
      sleep(rand/1000)
      span.add_event("dispatching to handler")
      trace.in_span("handler") do |child_span|
        sleep(rand/1000)
        child_span.add_event("dispatching to database")
        trace.in_span("db") do |db_span|
          db_span.add_event("querying database")
          sleep(rand/1000)
        end
        trace.in_span("external api") do |api_span|
          api_span.add_event("querying api")
          sleep(rand/1000)
        end
        sleep(rand/1000)
      end
    end

    buffer = iterate_span_nodes trace.root_span, 0, [] of String
    buffer.should eq ["request", "  handler", "    db", "    external api"]
  end
end

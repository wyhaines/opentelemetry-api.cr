require "./spec_helper"

describe OpenTelemetry::Trace, tags: ["Tracer"] do
  test_complex_trace = ->(trace : OpenTelemetry::Trace) do
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

  it "has an id" do
    checkout_config do
      provider = OpenTelemetry::TraceProvider.new(
        service_name: "my_app_or_library",
        service_version: "1.1.1",
        exporter: OpenTelemetry::Exporter.new)
      trace = provider.trace do |t|
        t.service_name = "microservice"
        t.service_version = "1.2.3"
        t.schema_url = "https://schema.open-telemetry.io/trace/v1/trace"
      end

      trace.id.hexstring.should_not eq Slice(UInt8).new(8, 0).hexstring
      trace.id.should eq trace.trace_id
      trace.schema_url.should eq "https://schema.open-telemetry.io/trace/v1/trace"

      trace.id.should_not eq(provider.trace do |t|
        t.service_name = "my_app_or_library"
        t.service_version = "1.1.1"
      end.id)
    end
  end

  it "can reate a span" do
    checkout_config do
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
      end
    end
  end

  it "can create a span using the default provider" do
    checkout_config do
      OpenTelemetry.configure do |cfg|
        cfg.exporter = OpenTelemetry::Exporter.new
      end
      trace = OpenTelemetry.trace
      trace.in_span("request") do |span|
        span.set_attribute("verb", "GET")
        span.set_attribute("url", "http://example.com/foo")
        span.add_event("dispatching to handler")
      end
      trace.output_stack.first.not_nil!.attributes.has_key?("verb").should be_true
      trace.output_stack.first.not_nil!.attributes.has_key?("url").should be_true
      trace.output_stack.first.not_nil!.attributes["verb"].value.should eq "GET"
    end
  end

  it "has an accessible span stack" do
    checkout_config do
      provider = OpenTelemetry::TraceProvider.new(
        service_name: "my_app_or_library",
        service_version: "1.1.1",
        exporter: OpenTelemetry::Exporter.new)
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
  end

  # it "has an accessible root span" do
  #   provider = OpenTelemetry::TraceProvider.new(
  #     service_name: "my_app_or_library",
  #     service_version: "1.1.1",
  #     exporter: OpenTelemetry::Exporter.new)
  #   trace = provider.trace do |t|
  #     t.service_name = "microservice"
  #     t.service_version = "1.2.3"
  #   end
  #   trace.root_span.should be_nil
  #   trace.in_span("request") do |span|
  #     span.set_attribute("verb", "GET")
  #     span.set_attribute("url", "http://example.com/foo")
  #     span.add_event("dispatching to handler")
  #     trace.root_span.should_not be_nil
  #     trace.root_span.should eq trace.span_stack[0]
  #   end
  # end

  it "produces traces and spans with the expected ids" do
    checkout_config do
      provider = OpenTelemetry::TraceProvider.new(
        service_name: "my_app_or_library",
        service_version: "1.1.1",
        exporter: OpenTelemetry::Exporter.new)
      trace = provider.trace do |t|
        t.service_name = "microservice a"
        t.service_version = "1.2.3"
      end

      test_complex_trace.call(trace)
    end
  end

  it "produces traces and spans with the expected ids when using spec compliant naming" do
    checkout_config do
      provider = OpenTelemetry::TracerProvider.new(
        service_name: "my_app_or_library",
        service_version: "1.1.1",
        exporter: OpenTelemetry::Exporter.new)
      tracer = provider.tracer do |t|
        t.service_name = "microservice a"
        t.service_version = "1.2.3"
      end

      test_complex_trace.call(tracer)
    end
  end

  it "produces traces and spans with the expected ids when using default trace creation syntax" do
    trace = OpenTelemetry.trace do |t|
      t.service_name = "microservice b"
      t.service_version = "1.2.3"
    end

    test_complex_trace.call(trace)
  end

  it "produces traces and spans with the expected ids when using a default config and default trace creation syntax" do
    checkout_config do
      OpenTelemetry.configure do |config|
        config.service_name = "microservice twee"
        config.service_version = "1.2.4"
        config.exporter = OpenTelemetry::Exporter.new
      end

      trace = OpenTelemetry.trace
      trace.provider.exporter.try(&.exporter).should be_a OpenTelemetry::Exporter::Null
      trace.service_name.should eq "microservice twee"
      trace.service_version.should eq "1.2.4"
      test_complex_trace.call(OpenTelemetry.trace)
    end
  end

  it "works when using spec compliant naming with a default config and default tracer creation syntax" do
    checkout_config do
      OpenTelemetry.configure do |config|
        config.service_name = "microservice twee"
        config.service_version = "1.2.4"
        config.exporter = OpenTelemetry::Exporter.new
      end

      tracer = OpenTelemetry.tracer
      tracer.provider.exporter.try(&.exporter).should be_a OpenTelemetry::Exporter::Null
      tracer.service_name.should eq "microservice twee"
      tracer.service_version.should eq "1.2.4"
      test_complex_trace.call(OpenTelemetry.tracer)
    end
  end

  it "has a resonable JSON representation" do
    checkout_config do
      OpenTelemetry.configure do |config|
        config.service_name = "microservice twee"
        config.service_version = "1.2.4"
        config.exporter = OpenTelemetry::Exporter.new
      end

      tracer = OpenTelemetry.tracer
      test_complex_trace.call(tracer)
      pj = JSON.parse(tracer.to_json)
      pj["type"].as_s.should eq "trace"
      pj["traceId"].as_s.presence.should be_a String
      pj["resource"]?.try(&.["service.name"]).should eq "microservice twee"
      pj["spans"]?.try(&.as_a.size).to_s.to_i.should be > 0
    end
  end
end

require "./src/opentelemetry-api"

provider = OpenTelemetry::TraceProvider.new(
  service_name: "my_app_or_library",
  service_version: "1.1.1",
  exporter: OpenTelemetry::Exporter.new(variant: :grpc) do |exporter|
    exporter.endpoint = "https://otlp.nr-data.net:4317"
    headers = HTTP::Headers.new
    headers["api-key"] = ENV["NEW_RELIC_LICENSE_KEY"]?.to_s
    exporter.headers = headers
  end
  )

trace = provider.trace do |t|
  t.service_name = "Crystal gRPC Test"
  t.service_version = "1.2.3"
end

puts "start trace"
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
puts "end trace"

sleep 10
puts "finished sleeping"
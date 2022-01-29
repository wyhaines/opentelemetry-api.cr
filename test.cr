require "./src/opentelemetry-api"

pp "MAKE PROVIDER"
provider = OpenTelemetry::TraceProvider.new(
  service_name: "Crystal OTel Test",
  service_version: "1.2.3",
  exporter: OpenTelemetry::Exporter.new(variant: :stdout) do |exporter|
    #exporter.endpoint = "https://staging-otlp.nr-data.net:4318/v1/traces"
    headers = HTTP::Headers.new
    headers["Api-Key"] = ENV["NEW_RELIC_LICENSE_KEY"]?.to_s
    #exporter.headers = headers
  end
)
pp "START LOOP"

1.times do |iteration|
  1.times do
    trace = provider.trace do |t|
      # All inherited config can be overridden here, if desired.
      t.service_name = "#{t.service_name} -- run #{iteration}"
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
    sleep rand() / 100
  end
end

sleep 20
puts "finished sleeping"

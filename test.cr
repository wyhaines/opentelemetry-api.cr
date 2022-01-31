require "./src/opentelemetry-api"

type = ARGV[0]?
iter = ARGV[1]?.nil? ? 1 : ARGV[1].to_i
count = ARGV[2]?.nil? ? 1 : ARGV[2].to_i

provider = OpenTelemetry::TraceProvider.new(
  service_name: "Crystal OTel Test",
  service_version: "1.2.3",
  exporter: type == "http" ? OpenTelemetry::Exporter.new(variant: :http) do |exporter|
    exporter = exporter.as(OpenTelemetry::Exporter::Http)
    exporter.endpoint = "https://staging-otlp.nr-data.net:4318/v1/traces"
    headers = HTTP::Headers.new
    headers["Api-Key"] = ENV["NEW_RELIC_LICENSE_KEY"]?.to_s
    exporter.headers = headers
  end : OpenTelemetry::Exporter.new(variant: :stdout) do |exporter|
    exporter = exporter.as(OpenTelemetry::Exporter::Stdout)
  end
)

iter.times do |iteration|
  count.times do
    spawn do
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
            db_span.add_event("querying database") do |event|
              event.set_attribute("db.type", "mysql")
              event.set_attribute("db.statement", "SELECT * FROM foo")
              event.set_attribute("db.params", ["bar", "baz"])
            end
            sleep(rand/1000)
          end
          trace.in_span("external api") do |api_span|
            api_span.add_event("querying api")
            sleep(rand/1000)
          end
          sleep(rand/1000)
        end
      end
    end
    sleep rand() / 100
  end
end

sleep type == "http" ? 10 : 0.1

![OpenTelemetry CI](https://img.shields.io/github/workflow/status/wyhaines/opentelemetry-api/OpenTelemetry%20CI?style=for-the-badge&logo=GitHub)
[![GitHub release](https://img.shields.io/github/release/wyhaines/opentelemetry-api.cr.svg?style=for-the-badge)](https://github.com/wyhaines/opentelemetry-api.cr/releases)
![GitHub commits since latest release (by SemVer)](https://img.shields.io/github/commits-since/wyhaines/opentelemetry-api.cr/latest?style=for-the-badge)

# OpenTelemetry-API

This library provides the base functionality for implementing services that utilize
OpenTelemetry to send or receive metrics, traces, and logs. This library is intended to be focused specifically on OpenTelemetry itself, with most higher level functionality implemented by other libraries which use this library.

As a general rule, naming conventions have been based on the standard glossary of OpenTelementry terms, as found at [https://opentelemetry.io/docs/concepts/glossary/](https://opentelemetry.io/docs/concepts/glossary/)

The general architecture of the implementation is guided by this document:

[https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md)

The TL;DR is that a `TraceProvider` is used to create a `Tracer`. A `Span` is created inside of the context of a `Tracer`, and one `Span` may nest inside of another.

## Caveats

This implementation was built using the Ruby version for loose guideance, but that full implementation is complicated. At this time, this implementation is a best first attempt at producing something that generally conforms to the expected structure and terminology of OpenTelemetry, while remaining a simple MVP.

The API is not yet considered stable, and may change in the future.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     otel:
       github: wyhaines/opentelemetry-api.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "opentelemetry-api"
```

## Global Tracer Provider
-----

```crystal
OpenTelemetry.configure do |config|
  config.service_name = "my_app_or_library"
  config.service_version = "1.1.1"
  config.exporter = OpenTelemetry::IOExporter.new(:STDOUT)
end
```

```crystal
tracer = OpenTelemetry.tracer_provider("my_app_or_library", "1.1.1")
tracer = OpenTelemetry.tracer_provider do |tracer|
  tracer.service_name = "my_app_or_library"
  tracer.service_version = "1.1.1"
end
```

## Tracer Providers as Objects With Unique Configuration
-----

```crystal
provider_a = OpenTelemetry::TracerProvider.new("my_app_or_library", "1.1.1")
provider_a.exporter = OpenTelemetry::IOExporter.new(:STDOUT)
```

```crystal
provider_b = OpenTelementry::TracerProvider.new do |config|
  config.service_name = "my_app_or_library"
  config.service_version = "1.1.1"
  config.exporter = OpenTelemetry::IOExporter.new(:STDOUT)
end
```

## Getting a Tracer From a Provider Object
-----

```crystal
tracer = provider_a.tracer # Inherit all configuration from the Provider Object
```

```crystal
tracer = provider_a.tracer("microservice foo", "1.2.3") # Override the configuration
```

```crystal
tracer = provider_a.tracer do |tracer|
  tracer.service_name = "microservice foo"
  tracer.service_version = "1.2.3"
end
```

## Creating Spans Using a Tracer
-----

```crystal
tracer.in_span("request") do |span|
  span.set_attribute("verb", "GET")
  span.set_attribute("url", "http://example.com/foo")
  span.add_event("dispatching to handler")
  tracer.in_span("handler") do |child_span|
    child_span.add_event("handling request")
    tracer.in_span("db") do |child_span|
      child_span.add_event("querying database")
    end
  end
end
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/otel/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kirk Haines](https://github.com/your-github-user) - creator and maintainer

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/wyhaines/tracer.cr?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/wyhaines/tracer.cr?style=for-the-badge)
![OpenTelemetry CI](https://img.shields.io/github/workflow/status/wyhaines/opentelemetry-api.cr/OpenTelemetry%20CI?style=for-the-badge&logo=GitHub)
[![GitHub release](https://img.shields.io/github/release/wyhaines/opentelemetry-api.cr.svg?style=for-the-badge)](https://github.com/wyhaines/opentelemetry-api.cr/releases)
![GitHub commits since latest release (by SemVer)](https://img.shields.io/github/commits-since/wyhaines/opentelemetry-api.cr/latest?style=for-the-badge)

# OpenTelemetry-API

# TODO: Documentation must be substantially expanded. Click through to the [Full Generated Documentation](#full-generated-documentation) for somewhat more complete documentation.

This library provides the base functionality for implementing services that utilize
OpenTelemetry to send or receive metrics, traces, and logs. This library is intended to be focused specifically on OpenTelemetry itself, with most higher level functionality implemented by other libraries which use this library.

**NOTE:** This shard currently breaks the OpenTelemetry spec because it bundles both API and SDK functionality into a single repository/library. This [issue](https://github.com/wyhaines/opentelemetry-api.cr/issues/5) will be addressed very soon, and the SDK functionality will all be moved over to [https://github.com/wyhaines/opentelemetry-sdk.cr](https://github.com/wyhaines/opentelemetry-sdk.cr).

As a general rule, naming conventions have been based on the standard glossary of OpenTelementry terms, as found at [https://opentelemetry.io/docs/concepts/glossary/](https://opentelemetry.io/docs/concepts/glossary/)

The general architecture of the implementation is guided by this document:

[https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md)

The TL;DR is that a `TracerProvider` is used to create a `Tracer`. A `Span` is created inside of the context of a `Tracer`, and one `Span` may nest inside of another.

## Full Generated Documentation

[https://wyhaines.github.io/opentelemetry-api.cr/](https://wyhaines.github.io/opentelemetry-api.cr/)

A lot of documentation needs to be added. PRs would be welcome!

## Discord

A Discord community for help and discussion with Crystal OpenTelemetry can be found at:

https://discord.gg/WKe9WWJ3HE

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     opentelemetry-api:
       github: wyhaines/opentelemetry-api.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "opentelemetry-api"
```

## Global Tracer Provider

The most common pattern for usage is to have a single global `TracerProvider` that is configured early in the program's execution. One may create an explicit configuration block, which will configure a globally held `TracerProvider`:

```crystal
OpenTelemetry.configure do |config|
  config.service_name = "my_app_or_library"
  config.service_version = "1.1.1"
  config.exporter = OpenTelemetry::Exporter.new(variant: :stdout)
end
```

One may also provision a `TracerProvider` object directly:

```crystal
tracer_provider = OpenTelemetry.tracer_provider("my_app_or_library", "1.1.1")
tracer_provider = OpenTelemetry.tracer_provider do |tracer|
  tracer.service_name = "my_app_or_library"
  tracer.service_version = "1.1.1"
end
```

This allows multiple providers with different configuration to be created:

```crystal
provider_a = OpenTelemetry::TracerProvider.new("my_app_or_library", "1.1.1")
provider_a.exporter = OpenTelemetry::Exporter.new(variant: :stdout)
```

```crystal
provider_b = OpenTelementry::TracerProvider.new do |config|
  config.service_name = "my_app_or_library"
  config.service_version = "1.1.1"
  config.exporter = OpenTelemetry::Exporter.new(variant: :stdout)
end
```

All `TracerProvider` configuration done in this way will respect OpenTelemetry SDK conventions for environment variable based configuration. Configuration delivered via environment variables supercedes configuration delivered in code. For example:

*environment variables*
```bash
OTEL_SERVICE_NAME="FIB ON COMMAND"
OTEL_SERVICE_VERSION="1.1.1"
OTEL_TRACES_EXPORTER="stdout"
OTEL_TRACES_SAMPLER=traceidratio
OTEL_TRACES_SAMPLER_ARG="0.10"
```

*configuration code*
```crystal
OpenTelemetry.configure do |config|
  config.service_name = "Fibonacci Server"
  config.service_version = Fibonacci::VERSION
  config.exporter = OpenTelemetry::Exporter.new(variant: :http) do |exporter|
    exporter = exporter.as(OpenTelemetry::Exporter::Http)
    exporter.endpoint = "https://otlp.nr-data.net:4318/v1/traces"
    headers = HTTP::Headers.new
    headers["api-key"] = ENV["NEW_RELIC_LICENSE_KEY"]?.to_s
    exporter.headers = headers
  end
end
```

In the above code, the code specifies a default set of configuration, which includes setting up an exporter to send traces to New Relic. The environment variable based configuration will override that configuration, however, and will instead setup a Stdout exporter with a sampler that only sends 10% of the traces to the exporter.

If one knows that one will be depending on environment variable based configuration, the initial configuration of the OpenTelemetry library can be simplified down to:

```crystal
OpenTelemetry.configure
```

The SDK will support the full range of environment variable based configuration ([https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/sdk-environment-variables.md](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/sdk-environment-variables.md)), but currently only a minimal subset is supported:

- OTEL_SERVICE_NAME
- OTEL_SERVICE_VERSION
- OTEL_SCHEMA_URL
- OTEL_TRACES_SAMPLER
- OTEL_TRACES_SAMPLER_ARG
- OTEL_TRACES_EXPORTER

## Getting a Tracer From a Provider Object

Most typically, when using a default `TracerProvider`, the SDK will be leveraged to produce a Tracer like so:

```crystal
OpenTelemetry.tracer.in_span("I am a span") do |span|
  span.set_attribute("key1", "value1")
  span.set_attribute("key2", "value2")
  span.set_attribute("key3", "value3")

  do_some_work
end
```

If one wishes to override the configuration held by a `TracerProvider` when creating a `Tracer`, new configuration can be provided in the `#tracer` method call:

```crystal
tracer = provider_a.tracer("microservice foo", "1.2.3") # Override the configuration
```

```crystal
tracer = provider_a.tracer do |tracer|
  tracer.service_name = "microservice foo"
  tracer.service_version = "1.2.3"
end
```

This new configuration only applies to the specific `Tracer` instance created. It does not alter the `TracerProvider` configuration.

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

- [Kirk Haines](https://github.com/wyhaines) - creator and maintainer

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/wyhaines/opentelemetry-api.cr?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/wyhaines/opentelemetry-api.cr?style=for-the-badge)

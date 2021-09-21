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

TODO: Write usage instructions here

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

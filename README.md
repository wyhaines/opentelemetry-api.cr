![OpenTelemetry CI](https://img.shields.io/github/actions/workflow/status/wyhaines/opentelemetry-api.cr/ci.yml?branch=main&style=for-the-badge&logo=GitHub)
[![GitHub release](https://img.shields.io/github/release/wyhaines/opentelemetry-api.cr.svg?style=for-the-badge)](https://github.com/wyhaines/opentelemetry-api.cr/releases)
![GitHub commits since latest release (by SemVer)](https://img.shields.io/github/commits-since/wyhaines/opentelemetry-api.cr/latest?style=for-the-badge)

# OpenTelemetry-API

This is an implementation of the OpenTelemetry API. The API layer provides a set of interface definitions, and NO-OP implementations of those interfaces. It is not useful on its own to instrument your code with OpenTelemetry, but rather is intended to be used by the [SDK], which provides the functionality behind the API interfaces defined in this repo.

## Full Generated Documentation

[https://wyhaines.github.io/opentelemetry-api.cr/](https://wyhaines.github.io/opentelemetry-api.cr/)

## Discord

A Discord community for help and discussion with Crystal OpenTelemetry can be found at:

https://discord.gg/WKe9WWJ3HE

## Installation

You will not normally directly use this shard. If you want to instrument your code with OpenTelemetry, see the [Instrumentation shard](https://github.com/wyhaines/opentelemetry-instrumentation.cr/) or the [SDK].

If you do have reason to use this shard directly, however:

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     opentelemetry-api:
       github: wyhaines/opentelemetry-api.cr
   ```

2. Run `shards install`

## Usage

To gain access to all of the API (i.e. NO-OP) implementations of the OTel API interfaces:

```crystal
require "opentelemetry-api"
```

This will define a set of classes and structs which implement the OpenTelemetry API interfaces with methods that do nothing.

If you only want access to the API interfaces (which is what the [SDK] uses):

```crystal
require "opentelemetry-api/src/interfaces"
```

## Development

If you want to help with development, [fork](https://github.com/wyhaines/opentelemetry-api.cr/fork) this repo. Do your work in a branch inside your fork, and when it is ready (and has specs), submit a PR. See [Contributing] below.

If you have a question or find an issue, you can [start a discussion](https://github.com/wyhaines/opentelemetry-api.cr/discussions/new) or [create an issue](https://github.com/wyhaines/opentelemetry-api.cr/issues/new/choose).

## Contributing

1. Fork it (https://github.com/wyhaines/opentelemetry-api.cr/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kirk Haines](https://github.com/wyhaines) - creator and maintainer

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/wyhaines/opentelemetry-api.cr?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/wyhaines/opentelemetry-api.cr?style=for-the-badge)

[Contributing]: #contributing
[SDK]: https://github.com/wyhaines/opentelemetry-sdk.cr

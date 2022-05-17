# Roadmap

This document represents a general set of goals for the project. It will change over time, and should be taken as a document that presents a general vision and plan for what is to come, and not as a document with specific tasks or milestones expressed. All specific goals and tasks will be found [as issues](https://github.com/wyhaines/opentelemetry-api.cr/issues).

- Separate SDK from the API.

  Currently the SDK and the API are combined into this single repository, but that is the wrong thing to be doing. The SDK capabilities must move [to their own repository](https://github.com/wyhaines/opentelemetry-sdk.cr).

- Improved Spec Compliance

  The current implementation is a work in progress, with areas where the spec is implemented incompletely or incorrectly. These omissions and transgressions must be addressed.

- Improve Documentation

  It is not expected that people will use the API directly, but there should be more robust documentation available for those who have a need to interact with it directly.

- Implement Baggage

  Support for TraceContext exists. Compliment this with support for the Baggage standard for data interchange.

- Add Log support

  The protobuf standard for Log is now stable, so Log support should be finalized and made usable, as it is already partially implemented.

- Add Metrics

  Metrics are stable, and are very important. They are, however, also complicated, but that can cannot be kicked down the road for too much longer. Metric support needs to be implemented.

- Make OTLP/gRPC work

  This largely depends on external work to ensure that there is a solid HTTP2 implementation available. Once that exists, however, OTLP/gRPC should be about done.
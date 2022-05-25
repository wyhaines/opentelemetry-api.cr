require "./ext"
require "csuuid"
# require "./proto/trace.pb"
# require "./proto/trace_service.pb"
require "./opentelemetry-api/resource"
require "./opentelemetry-api/trace_flags"
require "./opentelemetry-api/name"
require "./opentelemetry-api/version"
require "./opentelemetry-api/aliases"
require "./opentelemetry-api/trace_provider"
require "./opentelemetry-api/meter_provider"
require "./opentelemetry-api/log_provider"
require "./opentelemetry-api/text_map_propagator"
require "./exporter"
require "random/pcg32"

# ```
#
# ## Global Trace Provider
# ----------------------------------------------------------------
#
# OpenTelemetry.configure do |config|
#   config.service_name = "my_app_or_library"
#   config.service_version = "1.1.1"
#   config.exporter = OpenTelemetry::IOExporter.new(:STDOUT)
# end
#
# trace = OpenTelemetry.trace_provider("my_app_or_library", "1.1.1")
# trace = OpenTelemetry.trace_provider do |provider|
#   provider.service_name = "my_app_or_library"
#   provider.service_version = "1.1.1"
# end.trace
#
# ## Trace Providers as Objects With Unique Configuration
# ----------------------------------------------------------------
#
# provider_a = OpenTelemetry::TraceProvider.new("my_app_or_library", "1.1.1")
# provider_a.exporter = OpenTelemetry::IOExporter.new(:STDOUT)
#
# provider_b = OpenTelementry::TraceProvider.new do |config|
#   config.service_name = "my_app_or_library"
#   config.service_version = "1.1.1"
#   config.exporter = OpenTelemetry::IOExporter.new(:STDOUT)
# end
#
# ## Getting a Trace From a Provider Object
# ----------------------------------------------------------------
#
# trace = provider_a.trace # Inherit all configuration from the Provider Object
#
# trace = provider_a.trace("microservice foo", "1.2.3") # Override the configuration
#
# trace = provider_a.trace do |provider|
#   provider.service_name = "microservice foo"
#   provider.service_version = "1.2.3"
# end.trace
#
# ## Creating Spans Using a Trace
# ----------------------------------------------------------------
#
# trace.in_span("request") do |span|
#   span.set_attribute("verb", "GET")
#   span.set_attribute("url", "http://example.com/foo")
#   span.add_event("dispatching to handler")
#   trace.in_span("handler") do |child_span|
#     child_span.add_event("handling request")
#     trace.in_span("db") do |child_span|
#       child_span.add_event("querying database")
#     end
#   end
# end
module OpenTelemetry
  CSUUID.prng = Random::PCG32.new
  INSTANCE_ID = CSUUID.unique.to_s
  # The `config` class property provides direct access to the global default TracerProvider configuration.
  class_property config = TraceProvider::Configuration.new(Path[Process.executable_path.to_s].basename)

  # `provider` class property provides direct access to the global default Tracerprovider instance.
  class_property provider = TraceProvider.new

  # Use this method to configure the global trace provider.
  def self.configure(&block : TraceProvider::Configuration::Factory ->)
    @@config = TraceProvider::Configuration::Factory.build do |config_block|
      block.call(config_block)
    end

    provider.configure!(@@config)

    @@config
  end

  # Calling `configure` with no block results in a global TracerProvider being configured with the default configuration.
  # This is useful in cases where it is known that environment variable configuration is going to be used exclusively.
  #
  # ```crystal
  # # Depend on SDK environment variables ([https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/sdk-environment-variables.md](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/sdk-environment-variables.md))
  # # for all configuration.
  # OpenTelememtry.configure
  # ```
  #
  def self.configure
    configure do |_|
    end
  end

  def self.trace_provider
    provider
  end

  # Alias. The spec uses `TracerProvider`s, which manage `Tracer`s,
  # but which have internal methods and entities like `trace_id` and `TraceState`
  # and `TraceFlags`. Then this library was initially written, I opted for uniformly
  # consistent naming, but that violates the spec. Future versions will move towards
  # deprecating the uniform naming, in places where that naming violates the spec.
  # This is here to start preparing for that transition.
  def self.tracer_provider
    trace_provider
  end

  def self.trace_provider(&block : TraceProvider::Configuration::Factory ->)
    self.provider = TraceProvider.new do |cfg|
      block.call(cfg)
    end

    provider.merge_configuration(@@config)

    provider
  end

  # Alias. The spec uses `TracerProvider`s, which manage `Tracer`s,
  # but which have internal methods and entities like `trace_id` and `TraceState`
  # and `TraceFlags`. Then this library was initially written, I opted for uniformly
  # consistent naming, but that violates the spec. Future versions will move towards
  # deprecating the uniform naming, in places where that naming violates the spec.
  # This is here to start preparing for that transition.
  def self.tracer_provider(&block : TraceProvider::Configuration::Factory ->)
    self.trace_provider(&block)
  end

  def self.trace_provider(
    service_name : String = ENV["OTEL_SERVICE_NAME"]? || "",
    service_version : String = "",
    exporter = nil
  )
    self.provider = TraceProvider.new(
      service_name: service_name,
      service_version: service_version,
      exporter: exporter || Exporter.new(:abstract))
    provider.merge_configuration(@@config)

    provider
  end

  # Alias. The spec uses `TracerProvider`s, which manage `Tracer`s,
  # but which have internal methods and entities like `trace_id` and `TraceState`
  # and `TraceFlags`. Then this library was initially written, I opted for uniformly
  # consistent naming, but that violates the spec. Future versions will move towards
  # deprecating the uniform naming, in places where that naming violates the spec.
  # This is here to start preparing for that transition.
  def self.tracer_provider(
    service_name : String = ENV["OTEL_SERVICE_NAME"]? || "",
    service_version : String = "",
    exporter = nil
  )
    self.trace_provider(
      service_name: service_name,
      service_version: service_version,
      exporter: exporter)
  end

  def self.current_span
    Fiber.current.current_span
  end

  def self.trace
    trace = Fiber.current.current_trace
    r = trace ? trace : trace_provider.trace

    r
  end

  # Alias. The spec uses `TracerProvider`s, which manage `Tracer`s,
  # but which have internal methods and entities like `trace_id` and `TraceState`
  # and `TraceFlags`. Then this library was initially written, I opted for uniformly
  # consistent naming, but that violates the spec. Future versions will move towards
  # deprecating the uniform naming, in places where that naming violates the spec.
  # This is here to start preparing for that transition.
  def self.tracer
    trace
  end

  def self.trace
    trace = self.trace
    yield trace

    trace
  end

  # Alias. The spec uses `TracerProvider`s, which manage `Tracer`s,
  # but which have internal methods and entities like `trace_id` and `TraceState`
  # and `TraceFlags`. Then this library was initially written, I opted for uniformly
  # consistent naming, but that violates the spec. Future versions will move towards
  # deprecating the uniform naming, in places where that naming violates the spec.
  # This is here to start preparing for that transition.
  def self.tracer
    tracer = self.tracer
    yield tracer

    tracer
  end

  def self.instrumentation_scope
    Proto::Common::V1::InstrumentationScope.new(
      name: NAME,
      version: VERSION,
    )
  end

  def self.instrumentation_library
    instrumentation_scope
  end

  def self.handle_error(error)
  end
end

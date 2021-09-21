require "csuuid"
require "./proto/trace.pb"
require "./proto/trace_service.pb"
require "./opentelemetry-api/version"
require "./opentelemetry-api/aliases"
require "./opentelemetry-api/tracer_provider"
require "./exporter"

# ```
#
# ## Global Tracer Provider
# ----------------------------------------------------------------
#
# OpenTelemetry.configure do |config|
#   config.service_name = "my_app_or_library"
#   config.service_version = "1.1.1"
#   config.exporter = OpenTelemetry::IOExporter.new(:STDOUT)
# end
#
# tracer = OpenTelemetry.tracer_provider("my_app_or_library", "1.1.1")
# tracer = OpenTelemetry.tracer_provider do |tracer|
#   tracer.service_name = "my_app_or_library"
#   tracer.service_version = "1.1.1"
# end
#
# ## Tracer Providers as Objects With Unique Configuration
# ----------------------------------------------------------------
#
# provider_a = OpenTelemetry::TracerProvider.new("my_app_or_library", "1.1.1")
# provider_a.exporter = OpenTelemetry::IOExporter.new(:STDOUT)
#
# provider_b = OpenTelementry::TracerProvider.new do |config|
#   config.service_name = "my_app_or_library"
#   config.service_version = "1.1.1"
#   config.exporter = OpenTelemetry::IOExporter.new(:STDOUT)
# end
#
# ## Getting a Tracer From a Provider Object
# ----------------------------------------------------------------
#
# tracer = provider_a.tracer # Inherit all configuration from the Provider Object
#
# tracer = provider_a.tracer("microservice foo", "1.2.3") # Override the configuration
#
# tracer = provider_a.tracer do |tracer|
#   tracer.service_name = "microservice foo"
#   tracer.service_version = "1.2.3"
# end
#
# ## Creating Spans Using a Tracer
# ----------------------------------------------------------------
#
# tracer.in_span("request") do |span|
#   span.set_attribute("verb", "GET")
#   span.set_attribute("url", "http://example.com/foo")
#   span.add_event("dispatching to handler")
#   tracer.in_span("handler") do |child_span|
#     child_span.add_event("handling request")
#     tracer.in_span("db") do |child_span|
#       child_span.add_event("querying database")
#     end
#   end
# end
module OpenTelemetry
  class_property config = TracerProvider::Configuration.new(Path[Process.executable_path.to_s].basename)
  class_property provider = TracerProvider.new

  # Use this method to configure the global tracer provider.
  def self.configure(&block : TracerProvider::Configuration::Factory ->)
    @@config = TracerProvider::Configuration::Factory.build do |config_block|
      block.call(config_block)
    end
  end

  def self.tracer_provider
    provider.tracer
  end

  def self.tracer_provider(&block : TracerProvider::Configuration::Factory ->)
    provider = TracerProvider.new do |config|
      block.call(config)
    end

    provider.configure(@@config)

    provider.tracer
  end

  def self.tracer_provider(
    service_name : String,
    service_version : String = "",
    exporter : Exporter = NullExporter.new
  )
    provider = TracerProvider.new(
      service_name: service_name,
      service_version: service_version,
      exporter: exporter)
pp provider
pp @@config
    provider.configure(@@config)
pp provider
    provider.tracer
  end
end

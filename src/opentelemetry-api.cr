require "./ext"
require "csuuid"
require "./proto/trace.pb"
require "./proto/trace_service.pb"
require "./opentelemetry-api/version"
require "./opentelemetry-api/aliases"
require "./opentelemetry-api/trace_provider"
require "./exporter"

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
# trace = OpenTelemetry.trace_provider do |trace|
#   trace.service_name = "my_app_or_library"
#   trace.service_version = "1.1.1"
# end
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
# trace = provider_a.trace do |trace|
#   trace.service_name = "microservice foo"
#   trace.service_version = "1.2.3"
# end
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
  class_property config = TraceProvider::Configuration.new(Path[Process.executable_path.to_s].basename)
  class_property provider = TraceProvider.new

  # Use this method to configure the global trace provider.
  def self.configure(&block : TraceProvider::Configuration::Factory ->)
    @@config = TraceProvider::Configuration::Factory.build do |config_block|
      block.call(config_block)
    end
  end

  def self.trace_provider
    provider.trace
  end

  def self.trace_provider(&block : TraceProvider::Configuration::Factory ->)
    provider = TraceProvider.new do |cfg|
      block.call(cfg)
    end

    provider.merge_configuration(@@config)

    provider.trace
  end

  def self.trace_provider(
    service_name : String,
    service_version : String = "",
    exporter = nil
  )
    provider = TraceProvider.new(
      service_name: service_name,
      service_version: service_version,
      exporter: exporter || Exporter.new(:abstract))
    provider.merge_configuration(@@config)

    provider.trace
  end

  def self.handle_error(error)
  end
end
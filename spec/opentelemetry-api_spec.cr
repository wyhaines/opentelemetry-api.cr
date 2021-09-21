require "./spec_helper"
# ```
#
# ## Global Tracer Provider
# ----------------------------------------------------------------
#

#


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
describe OpenTelemetry do
  it "can setup global configuration" do
    OpenTelemetry.configure do |config|
      config.service_name = "my_app_or_library"
      config.service_version = "1.1.1"
      config.exporter = TestExporter.new
    end

    OpenTelemetry.config.service_name.should eq "my_app_or_library"
    OpenTelemetry.config.service_version.should eq "1.1.1"
    OpenTelemetry.config.exporter.should be_a TestExporter
  end

  it "can create a tracer with arguments passed to the class method" do
    tracer = OpenTelemetry.tracer_provider(
      "my_app_or_library",
      "1.1.1",
      OpenTelemetry::NullExporter.new)

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "1.1.1"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "can create a tracer via a block passed to the class method" do
    tracer = OpenTelemetry.tracer_provider do |tracer|
      tracer.service_name = "my_app_or_library"
      tracer.service_version = "1.1.1"
      tracer.exporter = OpenTelemetry::NullExporter.new
    end
  end
end

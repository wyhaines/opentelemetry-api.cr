require "./spec_helper"

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
  before_each do
    # Ensure that global state is always reset to a known starting point
    # before each spec runs.
    OpenTelemetry.configure do |config|
      config.service_name = "my_app_or_library"
      config.service_version = "1.1.1"
      config.exporter = TestExporter.new
    end
  end

  it "default configuration is setup as expected" do
    OpenTelemetry.config.service_name.should eq "my_app_or_library"
    OpenTelemetry.config.service_version.should eq "1.1.1"
    OpenTelemetry.config.exporter.should be_a TestExporter
  end

  it "can create a tracer with arguments passed to the class method" do
    tracer = OpenTelemetry.tracer_provider(
      "my_app_or_library",
      "1.2.3",
      OpenTelemetry::NullExporter.new)

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "1.2.3"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "substitutes the global provider configuration when values are not provided via method argument initialization" do
    tracer = OpenTelemetry.tracer_provider("my_app_or_library2")
    tracer.service_name.should eq "my_app_or_library2"
    tracer.service_version.should eq "1.1.1"
    tracer.exporter.should be_a TestExporter
  end

  it "can create a tracer via a block passed to the class method" do
    tracer = OpenTelemetry.tracer_provider do |t|
      t.service_name = "my_app_or_library"
      t.service_version = "1.2.3"
      t.exporter = OpenTelemetry::NullExporter.new
    end

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "1.2.3"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "substitutes the global provider configuration when values are not set via block initialization" do
    tracer = OpenTelemetry.tracer_provider do |t|
      t.service_version = "2.2.2"
    end

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "2.2.2"
    tracer.exporter.should be_a TestExporter
  end

  it "can return individual provider instances" do
    provider_a = OpenTelemetry::TracerProvider.new("my_app_or_library", "1.1.1")
    provider_b = OpenTelemetry::TracerProvider.new("my_app_or_library2", "2.2.2")

    provider_a.service_name.should eq "my_app_or_library"
    provider_b.service_name.should eq "my_app_or_library2"
    provider_a.should_not eq provider_b
    provider_a.service_version.should eq "1.1.1"
    provider_b.service_version.should eq "2.2.2"
  end

  it "can assign to provider configuration values after the provider is created" do
    provider = OpenTelemetry::TracerProvider.new("my_app_or_library", "1.1.1")
    provider.service_name = "my_app_or_library2"
    provider.service_version = "2.2.2"
    provider.exporter = OpenTelemetry::NullExporter.new

    provider.service_name.should eq "my_app_or_library2"
    provider.service_version.should eq "2.2.2"
    provider.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "can return individual provider instances using the block syntax" do
    provider_a = OpenTelemetry::TracerProvider.new do |config|
      config.service_version = "1.1.1"
    end
    provider_b = OpenTelemetry::TracerProvider.new do |config|
      config.service_version = "2.2.2"
    end

    provider_a.should_not eq provider_b
    provider_a.service_version.should eq "1.1.1"
    provider_b.service_version.should eq "2.2.2"
  end

  it "can create a tracer from a provider, inheriting the provider configuration" do
    provider = OpenTelemetry::TracerProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::NullExporter.new)
    tracer = provider.tracer

    tracer.is_a?(OpenTelemetry::Tracer).should be_true
    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "1.1.1"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "can create a tracer from a provider, overriding the provider configuration" do
    provider = OpenTelemetry::TracerProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::NullExporter.new)
    tracer = provider.tracer("microservice", "1.2.3")

    tracer.is_a?(OpenTelemetry::Tracer).should be_true
    tracer.service_name.should eq "microservice"
    tracer.service_version.should eq "1.2.3"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "can create a tracer from a provider, overriding the provider configuration using block syntax" do
    provider = OpenTelemetry::TracerProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::NullExporter.new)
    tracer = provider.tracer do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end

    tracer.is_a?(OpenTelemetry::Tracer).should be_true
    tracer.service_name.should eq "microservice"
    tracer.service_version.should eq "1.2.3"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end
end

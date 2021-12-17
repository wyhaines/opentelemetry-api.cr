require "./spec_helper"

describe OpenTelemetry::TracerProvider do
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

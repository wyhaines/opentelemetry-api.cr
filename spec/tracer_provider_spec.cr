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

  it "can replace the configuration of a TracerProvider with new configuration" do
    provider = OpenTelemetry::TracerProvider.new do |config|
      config.service_name = "my_app_or_library"
      config.service_version = "1.1.1"
      config.exporter = OpenTelemetry::NullExporter.new
      config.id_generator = OpenTelemetry::IdGenerator.new("random")
    end

    config2 = OpenTelemetry::TracerProvider::Configuration.new(
      service_name: "my_app_or_library2",
      service_version: "2.2.2",
      id_generator: OpenTelemetry::IdGenerator.new("unique")
    )

    provider.configure!(config2)
    provider.service_name.should eq "my_app_or_library2"
    provider.service_version.should eq "2.2.2"
    provider.exporter.should be_a OpenTelemetry::NullExporter
    provider.id_generator.should be_a OpenTelemetry::IdGenerator
    provider.id_generator.generator.should be_a OpenTelemetry::IdGenerator::Unique
  end

  it "can merge configuration with predictable outcomes" do
    provider_prime = OpenTelemetry::TracerProvider.new

    provider_clone = provider_prime.dup
    reconfig = OpenTelemetry::TracerProvider::Configuration.new(
      service_name: "my_app_or_library2"
    )
    provider_clone.merge_configuration(reconfig)
    provider_clone.service_name.should eq "my_app_or_library2"
    provider_clone.service_version.should eq ""

    provider_clone = provider_prime.dup
    reconfig = OpenTelemetry::TracerProvider::Configuration.new(
      service_version: "2.2.2"
    )
    provider_clone.merge_configuration(reconfig)
    provider_clone.service_name.should eq ""
    provider_clone.service_version.should eq "2.2.2"

    provider_clone = provider_prime.dup
    reconfig = OpenTelemetry::TracerProvider::Configuration.new(
      exporter: OpenTelemetry::NullExporter.new
    )
    provider_clone.merge_configuration(reconfig)
    provider_clone.exporter.should be_a OpenTelemetry::NullExporter

    provider_clone = provider_prime.dup
    reconfig = OpenTelemetry::TracerProvider::Configuration.new(
      id_generator: OpenTelemetry::IdGenerator.new("unique")
    )
    provider_clone.merge_configuration(reconfig)
    provider_clone.id_generator.should be_a OpenTelemetry::IdGenerator
    provider_clone.id_generator.generator.should be_a OpenTelemetry::IdGenerator::Unique
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

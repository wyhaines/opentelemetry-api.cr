require "./spec_helper"

describe OpenTelemetry::TraceProvider do
  it "validates the default configuration from the Factory" do
    config = OpenTelemetry::TracerProvider::Configuration::Factory.build
    if exporter = config.exporter.try(&.exporter)
      exporter.should be_a OpenTelemetry::Exporter::Null
    end
    config.service_name.should eq "unknown_service:crystal-run-spec.tmp"
  end

  it "can return individual provider instances" do
    provider_a = OpenTelemetry::TraceProvider.new("my_app_or_library", "1.1.1")
    provider_b = OpenTelemetry::TraceProvider.new("my_app_or_library2", "2.2.2", "http://foo.bar")

    provider_a.service_name.should eq "my_app_or_library"
    provider_b.service_name.should eq "my_app_or_library2"
    provider_a.should_not eq provider_b
    provider_a.service_version.should eq "1.1.1"
    provider_b.service_version.should eq "2.2.2"
    provider_a.schema_url.should eq ""
    provider_b.schema_url.should eq "http://foo.bar"
  end

  it "can assign to provider configuration values after the provider is created" do
    provider = OpenTelemetry::TraceProvider.new("my_app_or_library", "1.1.1")
    provider.service_name = "my_app_or_library2"
    provider.service_version = "2.2.2"
    provider.exporter = OpenTelemetry::Exporter.new(variant: :abstract)

    provider.service_name.should eq "my_app_or_library2"
    provider.service_version.should eq "2.2.2"
    provider.exporter.should be_a OpenTelemetry::Exporter
  end

  it "can replace the configuration of a TraceProvider with new configuration" do
    provider = OpenTelemetry::TraceProvider.new do |config|
      config.service_name = "my_app_or_library"
      config.service_version = "1.1.1"
      config.schema_url = "http://foo.bar"
      config.exporter = OpenTelemetry::Exporter.new(variant: :abstract)
      config.id_generator = OpenTelemetry::IdGenerator.new("random")
    end

    config2 = OpenTelemetry::TraceProvider::Configuration.new(
      service_name: "my_app_or_library2",
      service_version: "2.2.2",
      id_generator: OpenTelemetry::IdGenerator.new("unique")
    )

    provider.configure!(config2)
    provider.service_name.should eq "my_app_or_library2"
    provider.service_version.should eq "2.2.2"
    provider.schema_url.should eq ""
    provider.exporter.should be_nil
    provider.id_generator.should be_a OpenTelemetry::IdGenerator
    provider.id_generator.generator.should be_a OpenTelemetry::IdGenerator::Unique
  end

  it "can merge configuration with predictable outcomes" do
    provider_prime = OpenTelemetry::TraceProvider.new

    provider_clone = provider_prime.dup
    reconfig = OpenTelemetry::TraceProvider::Configuration.new(
      service_name: "my_app_or_library2",
      schema_url: "http://foo.bar",
    )
    provider_clone.merge_configuration(reconfig)
    provider_clone.service_name.should eq "my_app_or_library2"
    provider_clone.service_version.should eq ""
    provider_clone.schema_url.should eq "http://foo.bar"

    provider_clone = provider_prime.dup.configure!(
      OpenTelemetry::TraceProvider::Configuration.new(
        schema_url: "#"
      )
    )
    reconfig = OpenTelemetry::TraceProvider::Configuration.new(
      service_version: "2.2.2",
      schema_url: "http://foo.bar"
    )
    provider_clone.merge_configuration(reconfig)
    provider_clone.service_name.should eq ""
    provider_clone.service_version.should eq "2.2.2"
    provider_clone.schema_url.should eq "#"

    provider_clone = provider_prime.dup
    reconfig = OpenTelemetry::TraceProvider::Configuration.new(
      exporter: OpenTelemetry::Exporter.new
    )
    provider_clone.merge_configuration(reconfig)
    provider_clone.exporter.should be_a OpenTelemetry::Exporter

    provider_clone = provider_prime.dup
    reconfig = OpenTelemetry::TraceProvider::Configuration.new(
      id_generator: OpenTelemetry::IdGenerator.new("unique")
    )
    provider_clone.merge_configuration(reconfig)
    provider_clone.id_generator.should be_a OpenTelemetry::IdGenerator
    provider_clone.id_generator.generator.should be_a OpenTelemetry::IdGenerator::Unique
  end

  it "can return individual provider instances using the block syntax" do
    provider_a = OpenTelemetry::TraceProvider.new do |config|
      config.service_version = "1.1.1"
    end
    provider_b = OpenTelemetry::TraceProvider.new do |config|
      config.service_version = "2.2.2"
    end

    provider_a.should_not eq provider_b
    provider_a.service_version.should eq "1.1.1"
    provider_b.service_version.should eq "2.2.2"
  end

  it "can create a trace from a provider, inheriting the provider configuration" do
    provider = OpenTelemetry::TraceProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::Exporter.new)
    trace = provider.trace

    trace.is_a?(OpenTelemetry::Trace).should be_true
    trace.service_name.should eq "my_app_or_library"
    trace.service_version.should eq "1.1.1"
    trace.exporter.should be_a OpenTelemetry::Exporter
  end

  it "can create a trace from a provider, overriding the provider configuration" do
    provider = OpenTelemetry::TraceProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::Exporter.new)
    trace = provider.trace("microservice", "1.2.3")

    trace.is_a?(OpenTelemetry::Trace).should be_true
    trace.service_name.should eq "microservice"
    trace.service_version.should eq "1.2.3"
    trace.exporter.should be_a OpenTelemetry::Exporter
  end

  it "can create a trace from a provider, overriding the provider configuration using block syntax" do
    provider = OpenTelemetry::TraceProvider.new(
      service_name: "my_app_or_library",
      service_version: "1.1.1",
      exporter: OpenTelemetry::Exporter.new)
    trace = provider.trace do |t|
      t.service_name = "microservice"
      t.service_version = "1.2.3"
    end

    trace.is_a?(OpenTelemetry::Trace).should be_true
    trace.service_name.should eq "microservice"
    trace.service_version.should eq "1.2.3"
    trace.exporter.should be_a OpenTelemetry::Exporter
  end

  it "will honor environment variable configuration even when configuration is set in code" do
    checkout_config do
      ENV["OTEL_SERVICE_NAME"] = "i am a special app"
      ENV["OTEL_SERVICE_VERSION"] = "1.2.3"
      ENV["OTEL_TRACES_EXPORTER"] = "stdout"
      ENV["OTEL_TRACES_SAMPLER"] = "alwaysoff"
      OpenTelemetry.configure do |config|
        config.service_name = "microservice"
        config.service_version = "1.1.1"
      end

      begin
        trace = OpenTelemetry.trace
        trace.in_span("NOP")
        trace.is_a?(OpenTelemetry::Trace).should be_true
        trace.service_name.should eq "i am a special app"
        trace.service_version.should eq "1.2.3"
        if exptr = trace.exporter
          exptr.exporter.should be_a OpenTelemetry::Exporter::Stdout
        end
        OpenTelemetry.config.sampler.should be_a OpenTelemetry::Sampler::AlwaysOff
      ensure
        if trace
          # By fully closing the trace, we ensure that it doesn't exist as the Fiber.current_trace, either.
          trace.close_span
        end
      end
    end
  end
end

require "./spec_helper"

describe OpenTelemetry::TraceProvider::Configuration do
  it "can create a Configuration object" do
    config = OpenTelemetry::TraceProvider::Configuration.new(
      service_name: "test-service",
      service_version: "1.0.0",
      exporter: OpenTelemetry::Exporter.new,
      id_generator: "random")
    config.service_name.should eq "test-service"
    config.service_version.should eq "1.0.0"
    config.exporter.should be_a OpenTelemetry::Exporter
    config.id_generator.generator.should be_a OpenTelemetry::IdGenerator::Random
  end
end

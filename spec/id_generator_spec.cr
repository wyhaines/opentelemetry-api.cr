require "./spec_helper"

describe OpenTelemetry::API::IdGenerator do
  it "defines #initialize" do
    idg = OpenTelemetry::API::IdGenerator.new
    idg.should be_a(OpenTelemetry::API::IdGenerator)
    idg.generator.should be_a(OpenTelemetry::API::IdGenerator::Base)
  end

  it "defines #trace_id" do
    idg = OpenTelemetry::API::IdGenerator.new
    idg.trace_id.should be_nil
  end

  it "defines #span_id" do
    idg = OpenTelemetry::API::IdGenerator.new
    idg.span_id.should be_nil
  end

  it "defines IdGenerator.trace_id" do
    OpenTelemetry::API::IdGenerator.trace_id.should be_nil
  end

  it "defines IdGenerator.span_id" do
    OpenTelemetry::API::IdGenerator.span_id.should be_nil
  end
end

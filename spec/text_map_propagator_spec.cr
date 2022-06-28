require "./spec_helper"

describe OpenTelemetry::API::TextMapPropagator do
  it "defines #inject" do
    prop = OpenTelemetry::API::TextMapPropagator.new
    prop.inject(:fake_carrier, OpenTelemetry::Context.new).should be_nil
  end

  it "defines #extract" do
    prop = OpenTelemetry::API::TextMapPropagator.new
    prop.extract(:fake_carrier, OpenTelemetry::Context.new).should be_nil
  end

  it "defines #fields" do
    prop = OpenTelemetry::API::TextMapPropagator.new
    prop.fields.should be_nil
  end
end

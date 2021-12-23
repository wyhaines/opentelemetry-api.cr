require "./spec_helper"

describe OpenTelemetry::VERSION do
  it "has a defined VERSION" do
    OpenTelemetry::VERSION.empty?.should be_false
  end
end
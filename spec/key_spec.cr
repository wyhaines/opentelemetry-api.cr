require "./spec_helper"

describe OpenTelemetry::API::Context::Key do
  it "defines initialize" do
    key = OpenTelemetry::API::Context::Key.new(
      name: CSUUID.unique.to_s,
      context: OpenTelemetry::Context.new,
      id: CSUUID.unique)
    key.should be_a OpenTelemetry::API::Context::Key
    key.@name.should_not be_empty
    key.@context.should be_a(OpenTelemetry::Context)
    key.@id.to_s.should_not be_empty
  end

  it "defines value" do
    key = OpenTelemetry::API::Context::Key.new(
      name: CSUUID.unique.to_s,
      context: OpenTelemetry::Context.new,
      id: CSUUID.unique)
    key.value.should be_nil
  end

  it "defines get" do
    key = OpenTelemetry::API::Context::Key.new(
      name: CSUUID.unique.to_s,
      context: OpenTelemetry::Context.new,
      id: CSUUID.unique)
    key.get.should be_nil
  end

  it "defines <=>" do
    key1 = OpenTelemetry::API::Context::Key.new(
      name: CSUUID.unique.to_s,
      context: OpenTelemetry::Context.new,
      id: CSUUID.unique)
    key2 = OpenTelemetry::API::Context::Key.new(
      name: CSUUID.unique.to_s,
      context: OpenTelemetry::Context.new,
      id: CSUUID.unique)
    key1.should be < key2
  end

  it "defines name" do
    key = OpenTelemetry::API::Context::Key.new(
      name: CSUUID.unique.to_s,
      context: OpenTelemetry::Context.new,
      id: CSUUID.unique)
    key.name.should_not be_empty
  end

  it "defines id" do
    key = OpenTelemetry::API::Context::Key.new(
      name: CSUUID.unique.to_s,
      context: OpenTelemetry::Context.new,
      id: CSUUID.unique)
    key.id.to_s.should_not be_empty
  end

  it "defines context" do
    key = OpenTelemetry::API::Context::Key.new(
      name: CSUUID.unique.to_s,
      context: OpenTelemetry::Context.new,
      id: CSUUID.unique)
    key.context.should be_a(OpenTelemetry::Context)
  end
end

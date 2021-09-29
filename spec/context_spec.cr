require "./spec_helper"

describe OpenTelemetry::Context::Key do
  it "can return a unique key" do
    key = OpenTelemetry::Context::Key.new("key")
    key.name.should eq "key"
  end

  it "two keys with the same name should not be logically equivalent" do
    key1 = OpenTelemetry::Context::Key.new("key")
    key2 = OpenTelemetry::Context::Key.new("key")
    key1.name.should eq "key"
    key2.name.should eq "key"
    key1.should_not eq key2
  end

  it "two keys with the same name and id are logically equivalaent" do
    id = CSUUID.unique
    key1 = OpenTelemetry::Context::Key.new(name: "key", id: id)
    key2 = OpenTelemetry::Context::Key.new(name: "key", id: id)
    key1.name.should eq "key"
    key2.name.should eq "key"
    key1.id.should eq key2.id
    key1.should eq key2
  end
end

describe OpenTelemetry::Context do
end

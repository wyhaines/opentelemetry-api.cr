require "./spec_helper"

describe OpenTelemetry::API::Resource do
  it "defines #initialize" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    r.should be_a(OpenTelemetry::API::Resource)
  end

  it "defines #attributes" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    r.attributes.should be_a(Hash(String, OpenTelemetry::AnyAttribute))
  end

  it "defines #attributes=" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    new_h = Hash(String, OpenTelemetry::AnyAttribute).new
    r.attributes = new_h
    r.attributes.object_id.should eq new_h.object_id
  end

  it "defines #dropped_attribute_count" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    r.dropped_attribute_count.should eq 0
  end

  it "defines #dropped_attribute_count=" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    r.dropped_attribute_count = 1
    r.dropped_attribute_count.should eq 1
  end

  it "defines #[]" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    (r["key"] = "value").should be_nil
  end

  it "defines #get_attribute" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    (r.get_attribute("key")).should be_nil
  end

  it "defines #[]=" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    (r["key"] = "value").should be_nil
  end

  it "defines #set_attribute" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    (r.set_attribute("key", "value")).should be_nil
  end

  it "defines #empty?" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    r.empty?.should be_nil
  end

  it "defines #to_protobuf" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    r.to_protobuf.should be_nil
  end

  it "defines #to_json" do
    r = OpenTelemetry::API::Resource.new(Hash(Nil, Nil).new)
    r.to_json.should be_nil
    r.to_json(JSON::Builder.new(IO::Memory.new)).should be_nil
  end
end

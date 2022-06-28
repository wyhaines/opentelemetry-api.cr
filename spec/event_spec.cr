require "./spec_helper"

describe OpenTelemetry::API::Event do
  it "defines #initialize" do
    e = OpenTelemetry::API::Event.new("Event")
    e.@name.should eq "Event"

    e = OpenTelemetry::API::Event.new("Event2") do |ev2|
      ev2.@name.should eq "Event2"
    end
    e.@name.should eq "Event2"

    e = OpenTelemetry::API::Event.new("Event3", Hash(String, OpenTelemetry::AnyAttribute).new)
    e.@name.should eq "Event3"

    e = OpenTelemetry::API::Event.new("Event4", Hash(String, String | Int32).new)
    e.@name.should eq "Event4"
  end

  it "defines #name" do
    e = OpenTelemetry::API::Event.new("Event")
    e.name.should eq "Event"
  end

  it "defines #name=" do
    e = OpenTelemetry::API::Event.new("Event")
    e.name = "Event2"
    e.name.should eq "Event2"
  end

  it "defines #timestamp" do
    e = OpenTelemetry::API::Event.new("Event")
    e.timestamp.should be_a(Time::Span)
  end

  it "defines #timestamp=" do
    ts = Time.monotonic
    e = OpenTelemetry::API::Event.new("Event")
    e.timestamp = ts
    e.timestamp.should eq ts
  end

  it "defines #wall_timestamp" do
    e = OpenTelemetry::API::Event.new("Event")
    e.wall_timestamp.should be_a(Time)
    e.wall_timestamp.should be < Time.utc
  end

  it "defines #wall_timestamp=" do
    ts = Time.utc
    e = OpenTelemetry::API::Event.new("Event")
    e.wall_timestamp.should be > ts
    e.wall_timestamp = ts
    e.wall_timestamp.should eq ts
  end

  it "defines #parent_span" do
    e = OpenTelemetry::API::Event.new("Event")
    e.parent_span.should be_nil
  end

  it "defines #parent_span=" do
    e = OpenTelemetry::API::Event.new("Event")
    span = OpenTelemetry::API::Span.new
    e.parent_span = span
    e.parent_span.should be_a(OpenTelemetry::API::Span)
    e.parent_span.should eq span
  end

  it "defines #attributes" do
    e = OpenTelemetry::API::Event.new("Event")
    e.attributes.should be_a(Hash(String, OpenTelemetry::AnyAttribute))
  end

  it "defines #attributes=" do
    attr = Hash(String, OpenTelemetry::AnyAttribute).new
    e = OpenTelemetry::API::Event.new("Event")
    e.attributes = attr
    e.attributes.should be_a(Hash(String, OpenTelemetry::AnyAttribute))
    e.attributes.should eq attr
  end

  it "defines #[]" do
    e = OpenTelemetry::API::Event.new("Event")
    e["key"].should be_nil
  end

  it "defines #get_attribute" do
    e = OpenTelemetry::API::Event.new("Event")
    e.get_attribute("key").should be_nil
  end

  it "defines #[]=" do
    e = OpenTelemetry::API::Event.new("Event")
    e["key"] = "value"
    e["key"].should be_nil
  end

  it "defines #set_attribute" do
    e = OpenTelemetry::API::Event.new("Event")
    e.set_attribute("key", "value")
    e.get_attribute("key").should be_nil
  end

  it "defines #to_protobuf" do
    e = OpenTelemetry::API::Event.new("Event")
    e.to_protobuf.should be_nil
  end

  it "defines #to_json" do
    e = OpenTelemetry::API::Event.new("Event")
    e.to_json.should be_nil
    e.to_json(JSON::Builder.new(IO::Memory.new))
  end
end

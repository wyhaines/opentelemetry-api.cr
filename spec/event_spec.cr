require "./spec_helper"

describe OpenTelemetry::Event, tags: ["Event"] do
  it "can create an event with direct initialization" do
    event = OpenTelemetry::Event.new(
      name: "test_event",
      attributes: {
        "test_attribute" => "test_value",
      }
    )
    event.name.should eq "test_event"
    event["test_attribute"].should eq "test_value"
  end

  it "can create an event with block based initialization" do
    event = OpenTelemetry::Event.new do |e|
      e.name = "test_event"
      e.attributes = {
        "test_attribute" => "test_value",
      }
    end
    event.name.should eq "test_event"
    event["test_attribute"].should eq "test_value"
  end

  it "can get a JSON representation of the event" do
    event = OpenTelemetry::Event.new do |e|
      e.name = "test_event"
      e.attributes = {
        "test_attribute" => "test_value",
      }
    end

    json = JSON.parse(event.to_json)
    json["type"].as_s.should eq "event"
    json["name"].as_s.should eq "test_event"
    json["timestamp"].as_i64.should be > 1640135066531049984
  end
end

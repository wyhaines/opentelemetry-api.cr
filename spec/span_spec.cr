require "./spec_helper"

describe OpenTelemetry::API::Span do
  it "defines #initialize" do
    span = OpenTelemetry::API::Span.new("span")
    span.@name.should eq "span"
  end

  it "defines Span.builder" do
    span = OpenTelemetry::API::Span.build("span") do |spn|
      spn.@name.should eq "span"
      spn.name = "span2"
    end

    span.@name.should eq "span2"
  end

  it "defines #name" do
    span = OpenTelemetry::API::Span.new("span")
    span.name.should eq "span"
  end

  it "defines #name=" do
    span = OpenTelemetry::API::Span.new("span")
    span.name = "span2"
    span.name.should eq "span2"
  end

  it "defines #start" do
    span = OpenTelemetry::API::Span.new("span")
    span.start.should be_a(Time::Span)
    span.start.should be < Time.monotonic
  end

  it "defines #start=" do
    span = OpenTelemetry::API::Span.new("span")
    actual_start = Time.monotonic
    span.start = actual_start
    span.start.should be_a(Time::Span)
    span.start.should eq actual_start
  end

  it "defines #wall_start" do
    span = OpenTelemetry::API::Span.new("span")
    span.wall_start.should be_a(Time)
    span.wall_start.should be < Time.utc
  end

  it "defines #wall_start=" do
    span = OpenTelemetry::API::Span.new("span")
    actual_start = Time.utc
    span.wall_start = actual_start
    span.wall_start.should be_a(Time)
    span.wall_start.should eq actual_start
  end

  it "defines #finish" do
    span = OpenTelemetry::API::Span.new("span")
    span.finish.should be_nil
  end

  it "defines #finish=" do
    span = OpenTelemetry::API::Span.new("span")
    actual_finish = Time.monotonic
    span.finish = actual_finish
    span.finish.should be_a(Time::Span)
    span.finish.should eq actual_finish
  end

  it "defines #wall_finish" do
    span = OpenTelemetry::API::Span.new("span")
    span.wall_finish.should be_nil
  end

  it "defines #wall_finish=" do
    span = OpenTelemetry::API::Span.new("span")
    actual_finish = Time.utc
    span.wall_finish = actual_finish
    span.wall_finish.should be_a(Time)
    span.wall_finish.should eq actual_finish
  end

  it "defines #events" do
    span = OpenTelemetry::API::Span.new("span")
    span.events.should be_a(Array(OpenTelemetry::API::Event))
    span.events.size.should eq 0
  end

  it "defines #events=" do
    span = OpenTelemetry::API::Span.new("span")
    span.events = [OpenTelemetry::API::Event.new("event")]
    span.events.should be_a(Array(OpenTelemetry::API::Event))
  end

  it "defines #attributes" do
    span = OpenTelemetry::API::Span.new("span")
    span.attributes.should be_a(Hash(String, OpenTelemetry::AnyAttribute))
    span.attributes.size.should eq 0
  end

  it "defines #attributes=" do
    attr = Hash(String, OpenTelemetry::AnyAttribute).new
    span = OpenTelemetry::API::Span.new("span")
    span.attributes = attr
    span.attributes.should be_a(Hash(String, OpenTelemetry::AnyAttribute))
    span.attributes.should eq attr
  end

  it "defines #parent" do
    span = OpenTelemetry::API::Span.new("span")
    span.parent.should be_nil
  end

  it "defines #parent=" do
    span = OpenTelemetry::API::Span.new("span")
    span.parent = OpenTelemetry::API::Span.new("span2")
    span.parent.should be_a(OpenTelemetry::API::Span)
    span.name.should eq "span"
    if span_parent = span.parent
      span_parent.name.should eq "span2"
    end
  end

  it "defines #children" do
    span = OpenTelemetry::API::Span.new("span")
    span.children.should be_a(Array(OpenTelemetry::API::Span))
    span.children.size.should eq 0
  end

  it "defines #children=" do
    span = OpenTelemetry::API::Span.new("span")
    span.children = [OpenTelemetry::API::Span.new("span2")]
    span.children.should be_a(Array(OpenTelemetry::API::Span))
    span.children.size.should eq 1
    if span_child = span.children[0]
      span_child.name.should eq "span2"
    end
  end

  it "defines #context" do
    span = OpenTelemetry::API::Span.new("span")
    span.context.should be_a(OpenTelemetry::API::SpanContext)
  end

  it "defines #context=" do
    ctx = OpenTelemetry::API::SpanContext.new
    span = OpenTelemetry::API::Span.new("span")
    span.context = ctx
    span.context.should be_a(OpenTelemetry::API::SpanContext)
    span.context.should eq ctx
  end

  it "defines #kind" do
    span = OpenTelemetry::API::Span.new("span")
    span.kind.should be_a(OpenTelemetry::API::Span::Kind)
    span.kind.should eq OpenTelemetry::API::Span::Kind::Internal
  end

  it "defines #kind=" do
    span = OpenTelemetry::API::Span.new("span")
    span.kind = OpenTelemetry::API::Span::Kind::Server
    span.kind.should be_a(OpenTelemetry::API::Span::Kind)
    span.kind.should eq OpenTelemetry::API::Span::Kind::Server
  end

  it "defines #status" do
    span = OpenTelemetry::API::Span.new("span")
    span.status.should be_a(OpenTelemetry::API::Status)
    span.status.code.value.should eq 0
  end

  it "defines #status=" do
    span = OpenTelemetry::API::Span.new("span")
    new_status = OpenTelemetry::API::Status.new
    new_status.code = OpenTelemetry::API::Status::StatusCode::Ok
    span.status = new_status
    span.status.should be_a(OpenTelemetry::API::Status)
    span.status.code.value.should eq 1
  end

  it "defines #is_recording" do
    span = OpenTelemetry::API::Span.new("span")
    span.is_recording.should be_true
  end

  it "defines #is_recording=" do
    span = OpenTelemetry::API::Span.new("span")
    span.is_recording = false
    span.is_recording.should be_false
  end

  it "defines #recording?" do
    span = OpenTelemetry::API::Span.new("span")
    span.recording?.should be_nil
  end

  it "defines #[]" do
    span = OpenTelemetry::API::Span.new("span")
    span["key"].should be_nil
  end

  it "defines #get_attribute" do
    span = OpenTelemetry::API::Span.new("span")
    span.get_attribute("key").should be_nil
  end

  it "defines #[]=" do
    span = OpenTelemetry::API::Span.new("span")
    (span["key"] = "value").should be_nil
  end

  it "defines #set_attribute" do
    span = OpenTelemetry::API::Span.new("span")
    span.set_attribute("key", "value").should be_nil
  end

  it "defines #add_event" do
    span = OpenTelemetry::API::Span.new("span")
    span.add_event("event").should be_nil

    span.add_event("event2") do |event|
      event.@name.should eq "event2"
    end
  end
end

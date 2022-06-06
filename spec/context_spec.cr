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
  it "should have a usable base context" do
    OpenTelemetry::Context["foo"] = "bar"
    OpenTelemetry::Context["foo"].should eq "bar"
    OpenTelemetry::Context::Key.new("foo").value.should eq "bar"
  end

  it "should allow an imperative attach and detach of a context" do
    entries = SplayTreeMap(String, String).new
    entries["foo"] = "bar"
    entries["bar"] = "baz"
    token = OpenTelemetry::Context.attach(entries)
    OpenTelemetry::Context["foo"].should eq "bar"
    OpenTelemetry::Context["bar"].should eq "baz"
    OpenTelemetry::Context.detach(token)
  end

  it "should allow an implicit attach and detach of a context" do
    entries = SplayTreeMap(String, String).new
    entries["foo"] = "bar"
    entries["bif"] = "baz"
    OpenTelemetry::Context.with(entries) do
      OpenTelemetry::Context["foo"].should eq "bar"
      OpenTelemetry::Context["bif"].should eq "baz"
    end
  end

  it "should allow attachment of a new context for the duration of a block" do
    OpenTelemetry::Context["one"] = "1"
    OpenTelemetry::Context["two"] = "2"
    OpenTelemetry::Context.with({"three" => "3"}) do
      OpenTelemetry::Context["one"].should eq "1"
      OpenTelemetry::Context["two"].should eq "2"
      OpenTelemetry::Context["three"].should eq "3"
    end
    OpenTelemetry::Context["one"].should eq "1"
    OpenTelemetry::Context["two"].should eq "2"
    OpenTelemetry::Context["three"]?.should be_nil
  end

  it "context is per-fiber" do
    fiber_a_context_stack_id = nil
    fiber_b_context_stack_id = nil
    fiber_a_context_id = nil
    fiber_b_context_id = nil

    finished = Channel(Bool).new

    spawn(name: "Fiber A") do
      fiber_a_context_stack_id = OpenTelemetry::Context.stack.object_id
      fiber_a_context_id = OpenTelemetry::Context.current.object_id
      finished.send(true)
    end

    spawn(name: "Fiber B") do
      fiber_b_context_stack_id = OpenTelemetry::Context.stack.object_id
      fiber_b_context_id = OpenTelemetry::Context.current.object_id
      finished.send(true)
    end

    finished.receive
    finished.receive

    fiber_a_context_stack_id.should_not eq fiber_b_context_stack_id
    fiber_a_context_id.should_not eq fiber_b_context_id
    fiber_b_context_stack_id.should_not eq fiber_a_context_stack_id
    fiber_b_context_id.should_not eq fiber_a_context_id
  end
end

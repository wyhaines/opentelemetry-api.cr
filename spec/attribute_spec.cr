require "./spec_helper"

describe OpenTelemetry::Attribute do
  it "can create a string attribute" do
    attr = OpenTelemetry::Attribute.new("key", "value")
    attr.value.should eq "value"
  end

  it "can create a bool attribute" do
    attr = OpenTelemetry::Attribute.new("key", true)
    attr.value.should eq true
  end

  it "can create an int32 attribute" do
    attr = OpenTelemetry::Attribute.new("key", 42)
    attr.value.should eq 42
  end

  it "can create an int64 attribute" do
    attr = OpenTelemetry::Attribute.new("key", 42_i64)
    attr.value.should eq 42_i64
  end

  it "can create a float64 attribute" do
    attr = OpenTelemetry::Attribute.new("key", 42.0)
    attr.value.should eq 42.0_f64
  end

  it "can create a string array attribute" do
    attr = OpenTelemetry::Attribute.new("key", ["value1", "value2"])
    attr.value.should eq ["value1", "value2"]
    attr.value << "value3"
    attr.value.should eq ["value1", "value2", "value3"]
  end

  it "can create a bool array attribute" do
    attr = OpenTelemetry::Attribute.new("key", [true, false])
    attr.value.should eq [true, false]
    attr.value << true
    attr.value.should eq [true, false, true]
  end

  it "can create an int32 array attribute" do
    attr = OpenTelemetry::Attribute.new("key", [42, 84])
    attr.value.should eq [42, 84]
    attr.value << 42
    attr.value.should eq [42, 84, 42]
  end

  it "can create an int64 array attribute" do
    attr = OpenTelemetry::Attribute.new("key", [42_i64, 84_i64])
    attr.value.should eq [42_i64, 84_i64]
    attr.value << 42_i64
    attr.value.should eq [42_i64, 84_i64, 42_i64]
  end

  it "can create a float64 array attribute" do
    attr = OpenTelemetry::Attribute.new("key", [42.0, 84.0])
    attr.value.should eq [42.0_f64, 84.0_f64]
    attr.value << 42.0
    attr.value.should eq [42.0_f64, 84.0_f64, 42.0_f64]
  end
end

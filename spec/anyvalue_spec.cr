require "./spec_helper"

describe OpenTelemetry::AnyValue do
  it "can create a string value" do
    attr = OpenTelemetry::AnyValue.new("value")
    attr.value.should eq "value"
  end

  it "can create a bool value" do
    attr = OpenTelemetry::AnyValue.new(true)
    attr.value.should eq true
  end

  it "can create an int32 value" do
    attr = OpenTelemetry::AnyValue.new(42)
    attr.value.should eq 42
  end

  it "can create an int64 value" do
    attr = OpenTelemetry::AnyValue.new(42_i64)
    attr.value.should eq 42_i64
  end

  it "can create a float64 value" do
    attr = OpenTelemetry::AnyValue.new(42.0)
    attr.value.should eq 42.0_f64
  end

  it "can create a string array value" do
    attr = OpenTelemetry::AnyValue.new(["value1", "value2"])
    attr.value.should eq ["value1", "value2"]
    attr << "value3"
    attr.value.should eq ["value1", "value2", "value3"]
  end

  it "can create a bool array attribute" do
    attr = OpenTelemetry::AnyValue.new([true, false])
    attr.value.should eq [true, false]
    attr << true
    attr.value.should eq [true, false, true]
  end

  it "can create an int32 array attribute" do
    attr = OpenTelemetry::AnyValue.new([42, 84])
    attr.value.should eq [42, 84]
    attr << 42
    attr.value.should eq [42, 84, 42]
  end

  it "can create an int64 array attribute" do
    attr = OpenTelemetry::AnyValue.new([42_i64, 84_i64])
    attr.value.should eq [42_i64, 84_i64]
    attr << 42_i64
    attr.value.should eq [42_i64, 84_i64, 42_i64]
  end

  it "can create a float64 array attribute" do
    attr = OpenTelemetry::AnyValue.new([42.0, 84.0])
    attr.value.should eq [42.0_f64, 84.0_f64]
    attr << 42.0
    attr.value.should eq [42.0_f64, 84.0_f64, 42.0_f64]
  end

  it "can create an AnyValue for a String" do
    OpenTelemetry::AnyValue.new("value1")
  end

  it "can create an AnyValue for a Bool" do
    OpenTelemetry::AnyValue.new(true)
  end

  it "can create an AnyValue for an Int32" do
    OpenTelemetry::AnyValue.new(42)
  end

  it "can create an AnyValue for an Int64" do
    OpenTelemetry::AnyValue.new(42_i64)
  end

  it "can create an AnyValue for a Float64" do
    OpenTelemetry::AnyValue.new(42.0)
  end

  it "can create an AnyValue for an UInt64" do
    OpenTelemetry::AnyValue.new(42_u64).value.should eq 42_i64
    OpenTelemetry::AnyValue.new(42_u64).value.should be_a Int64
  end

  it "can create an AnyValue for a String array" do
    OpenTelemetry::AnyValue.new(["value1", "value2"])
  end

  it "can create an AnyValue for a Bool array" do
    OpenTelemetry::AnyValue.new([true, false])
  end

  it "can create an AnyValue for an Int32 array" do
    OpenTelemetry::AnyValue.new([42, 84])
  end

  it "can create an AnyValue for an Int64 array" do
    OpenTelemetry::AnyValue.new([42_i64, 84_i64])
  end

  it "can create an AnyValue for a Float64 array" do
    OpenTelemetry::AnyValue.new([42.0, 84.0])
  end

  it "can append to an AnyValue that contains an array" do
    attr = OpenTelemetry::AnyValue.new([42, 84])
    attr << 42
    attr.value.should eq [42, 84, 42]

    attr = OpenTelemetry::AnyValue.new(["value1", "value2"])
    attr << "value3"
    attr.value.should eq ["value1", "value2", "value3"]

    attr = OpenTelemetry::AnyValue.new([true, false])
    attr << true
    attr.value.should eq [true, false, true]

    attr = OpenTelemetry::AnyValue.new([42_i64, 84_i64])
    attr << 42_i64
    attr.value.should eq [42_i64, 84_i64, 42_i64]

    attr = OpenTelemetry::AnyValue.new([42.0, 84.0])
    attr << 42.0
    attr.value.should eq [42.0_f64, 84.0_f64, 42.0_f64]
  end

  it "can transparently index appropriate attributes" do
    attr = OpenTelemetry::AnyValue.new([42, 84])
    attr2 = OpenTelemetry::AnyValue.new("abcdefghijklmnopqrstuvwxyz")
    attr[0].should eq 42
    attr[1].should eq 84
    attr[1] = 43
    attr[1].should eq 43

    attr2[0].should eq 'a'
    attr2[1].should eq 'b'
    attr2[25].should eq 'z'
  end
end

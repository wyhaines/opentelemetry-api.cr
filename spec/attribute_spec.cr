require "./spec_helper"

describe OpenTelemetry::Attribute do
  it "can create a string attribute" do
    attr = OpenTelemetry::Attribute(String).new("key", "value")
    attr.value.should eq "value"
  end

  it "can create a bool attribute" do
    attr = OpenTelemetry::Attribute(Bool).new("key", true)
    attr.value.should eq true
  end

  it "can create an int32 attribute" do
    attr = OpenTelemetry::Attribute(Int32).new("key", 42)
    attr.value.should eq 42
  end

  it "can create an int64 attribute" do
    attr = OpenTelemetry::Attribute(Int64).new("key", 42_i64)
    attr.value.should eq 42_i64
  end

  it "can create a float64 attribute" do
    attr = OpenTelemetry::Attribute(Float64).new("key", 42.0)
    attr.value.should eq 42.0_f64
  end

  it "can create a string array attribute" do
    attr = OpenTelemetry::Attribute(Array(String)).new("key", ["value1", "value2"])
    attr.value.should eq ["value1", "value2"]
    attr.value << "value3"
    attr.value.should eq ["value1", "value2", "value3"]
  end

  it "can create a bool array attribute" do
    attr = OpenTelemetry::Attribute(Array(Bool)).new("key", [true, false])
    attr.value.should eq [true, false]
    attr.value << true
    attr.value.should eq [true, false, true]
  end

  it "can create an int32 array attribute" do
    attr = OpenTelemetry::Attribute(Array(Int32)).new("key", [42, 84])
    attr.value.should eq [42, 84]
    attr.value << 42
    attr.value.should eq [42, 84, 42]
  end

  it "can create an int64 array attribute" do
    attr = OpenTelemetry::Attribute(Array(Int64)).new("key", [42_i64, 84_i64])
    attr.value.should eq [42_i64, 84_i64]
    attr.value << 42_i64
    attr.value.should eq [42_i64, 84_i64, 42_i64]
  end

  it "can create a float64 array attribute" do
    attr = OpenTelemetry::Attribute(Array(Float64)).new("key", [42.0, 84.0])
    attr.value.should eq [42.0_f64, 84.0_f64]
    attr.value << 42.0
    attr.value.should eq [42.0_f64, 84.0_f64, 42.0_f64]
  end

  it "can create an AnyAttribute for a String" do
    OpenTelemetry::AnyAttribute.new("key1", "value1")
  end

  it "can create an AnyAttribute for a Bool" do
    OpenTelemetry::AnyAttribute.new("key2", true)
  end

  it "can create an AnyAttribute for an Int32" do
    OpenTelemetry::AnyAttribute.new("key3", 42)
  end

  it "can create an AnyAttribute for an Int64" do
    OpenTelemetry::AnyAttribute.new("key4", 42_i64)
  end

  it "can create an AnyAttribute for a Float64" do
    OpenTelemetry::AnyAttribute.new("key5", 42.0)
  end

  it "can create an AnyAttribute for a String array" do
    OpenTelemetry::AnyAttribute.new("key6", ["value1", "value2"])
  end

  it "can create an AnyAttribute for a Bool array" do
    OpenTelemetry::AnyAttribute.new("key7", [true, false])
  end

  it "can create an AnyAttribute for an Int32 array" do
    OpenTelemetry::AnyAttribute.new("key8", [42, 84])
  end

  it "can create an AnyAttribute for an Int64 array" do
    OpenTelemetry::AnyAttribute.new("key9", [42_i64, 84_i64])
  end

  it "can create an AnyAttribute for a Float64 array" do
    OpenTelemetry::AnyAttribute.new("key10", [42.0, 84.0])
  end

  it "can append to an AnyAttribute that contains an array" do
    attr = OpenTelemetry::AnyAttribute.new("key11", [42, 84])
    attr << 42
    attr.value.should eq [42, 84, 42]

    attr = OpenTelemetry::AnyAttribute.new("key12", ["value1", "value2"])
    attr << "value3"
    attr.value.should eq ["value1", "value2", "value3"]

    attr = OpenTelemetry::AnyAttribute.new("key13", [true, false])
    attr << true
    attr.value.should eq [true, false, true]

    attr = OpenTelemetry::AnyAttribute.new("key14", [42_i64, 84_i64])
    attr << 42_i64
    attr.value.should eq [42_i64, 84_i64, 42_i64]

    attr = OpenTelemetry::AnyAttribute.new("key15", [42.0, 84.0])
    attr << 42.0
    attr.value.should eq [42.0_f64, 84.0_f64, 42.0_f64]
  end

  it "can access the key and value of the stored Attribute within an AnyAttribute" do
    attr = OpenTelemetry::AnyAttribute.new("key16", "value1")
    attr.key.should eq "key16"
    attr.value.should eq "value1"
  end

  it "can transparently index appropriate attributes" do
    attr = OpenTelemetry::AnyAttribute.new("key17", [42, 84])
    attr2 = OpenTelemetry::AnyAttribute.new("key18", "abcdefghijklmnopqrstuvwxyz")
    attr[0].should eq 42
    attr[1].should eq 84
    attr[1] = 43
    attr[1].should eq 43

    attr2[0].should eq 'a'
    attr2[1].should eq 'b'
    attr2[25].should eq 'z'
  end
end

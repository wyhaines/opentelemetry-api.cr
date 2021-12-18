require "./spec_helper"

describe OpenTelemetry::IdGenerator do
  it "can create a default IdGenerator" do
    generator = OpenTelemetry::IdGenerator.new
    generator.should be_a OpenTelemetry::IdGenerator
    generator.generator.should be_a OpenTelemetry::IdGenerator::Unique
  end

  it "can create specific generator types when specified" do
    OpenTelemetry::IdGenerator.new("random").generator.should be_a OpenTelemetry::IdGenerator::Random
    OpenTelemetry::IdGenerator.new("unique").generator.should be_a OpenTelemetry::IdGenerator::Unique
  end

  it "creates a Random generator that returns proper span ids" do
    generator = OpenTelemetry::IdGenerator.new("random")
    generator.generator.should be_a OpenTelemetry::IdGenerator::Random
    generator.span_id.should be_a Slice(UInt8)
    generator.span_id.size.should eq 8

    # The next spec has a very small statistical possibility of a false negative.
    # Odds are it will never happen. If it does, rerun the specs and buy a lottery ticket. :)

    all_different = false

    3.times do
      first_id = generator.span_id
      second_id = generator.span_id
      third_id = generator.span_id

      all_different = true if first_id != second_id && first_id != third_id && second_id != third_id
      break if all_different
    end

    all_different.should be_true
  end

  it "create a Random generator that returns proper trace ids" do
    generator = OpenTelemetry::IdGenerator.new("random")
    generator.generator.should be_a OpenTelemetry::IdGenerator::Random
    generator.trace_id.should be_a Slice(UInt8)
    generator.trace_id.size.should eq 16

    # The next spec has a very small statistical possibility of a false negative.
    # Odds are it will never happen. If it does, rerun the specs and buy a lottery ticket. :)

    all_different = false

    3.times do
      first_id = generator.trace_id
      second_id = generator.trace_id
      third_id = generator.trace_id

      all_different = true if first_id != second_id && first_id != third_id && second_id != third_id
      break if all_different
    end

    all_different.should be_true
  end

  it "creates a Unique generator that returns proper span ids" do
    generator = OpenTelemetry::IdGenerator.new("unique")
    generator.generator.should be_a OpenTelemetry::IdGenerator::Unique
    generator.span_id.should be_a Slice(UInt8)
    generator.span_id.size.should eq 8
    generator.span_id.should_not eq generator.span_id

    # The next spec has a very small statistical possibility of a false negative.
    # Odds are it will never happen. If it does, rerun the specs and buy a lottery ticket. :)

    all_different = false

    first_id = second_id = third_id = uninitialized Slice(UInt8)
    3.times do
      first_id = generator.span_id
      second_id = generator.span_id
      third_id = generator.span_id

      all_different = true if first_id != second_id && first_id != third_id && second_id != third_id
      break if all_different
    end

    all_different.should be_true
    second_id.hexstring.should be > first_id.hexstring
    third_id.hexstring.should be > second_id.hexstring
  end

  it "creates a Unique generator that returns proper trace ids" do
    generator = OpenTelemetry::IdGenerator.new("unique")
    generator.generator.should be_a OpenTelemetry::IdGenerator::Unique
    generator.trace_id.should be_a Slice(UInt8)
    generator.trace_id.size.should eq 16
    generator.trace_id.should_not eq generator.trace_id

    # The next spec has a very small statistical possibility of a false negative.
    # Odds are it will never happen. If it does, rerun the specs and buy a lottery ticket. :)

    all_different = false

    first_id = second_id = third_id = uninitialized Slice(UInt8)
    3.times do
      first_id = generator.trace_id
      second_id = generator.trace_id
      third_id = generator.trace_id

      all_different = true if first_id != second_id && first_id != third_id && second_id != third_id
      break if all_different
    end

    all_different.should be_true
    second_id.hexstring.should be > first_id.hexstring
    third_id.hexstring.should be > second_id.hexstring
  end
end

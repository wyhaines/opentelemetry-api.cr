require "./spec_helper"

describe OpenTelemetry::Trace::InvalidSpanInSpanStackError do
  it "raises the expected message when called with no arguments" do
    expect_raises(
      klass: OpenTelemetry::Trace::InvalidSpanInSpanStackError,
      message: /Invalid Spans in the Span Stack/
    ) do
      raise OpenTelemetry::Trace::InvalidSpanInSpanStackError.new
    end
  end

  it "raises the expected message when called with an expected span" do
    expect_raises(
      klass: OpenTelemetry::Trace::InvalidSpanInSpanStackError,
      message: /Invalid Spans in the Span Stack. Expected "EXPECTED"/
    ) do
      raise OpenTelemetry::Trace::InvalidSpanInSpanStackError.new(expected: "EXPECTED")
    end
  end

  it "raises the expected message when called with a found span" do
    expect_raises(
      klass: OpenTelemetry::Trace::InvalidSpanInSpanStackError,
      message: /Invalid Spans in the Span Stack. Found "FOUND"/
    ) do
      raise OpenTelemetry::Trace::InvalidSpanInSpanStackError.new(found: "FOUND")
    end
  end

  it "raises the expected message when called with both an expected span and a found span" do
    expect_raises(
      klass: OpenTelemetry::Trace::InvalidSpanInSpanStackError,
      message: /Invalid Spans in the Span Stack. Expected "EXPECTED" but found "FOUND"/
    ) do
      raise OpenTelemetry::Trace::InvalidSpanInSpanStackError.new(expected: "EXPECTED", found: "FOUND")
    end
  end
end

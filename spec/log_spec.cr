require "./spec_helper"

describe OpenTelemetry::Log do
  it "can transform a severity number into a severity label" do
    OpenTelemetry::Log.severity_from_number(1).should eq OpenTelemetry::Log::Level::Trace
    OpenTelemetry::Log.severity_from_number(2).should eq OpenTelemetry::Log::Level::Trace2
    OpenTelemetry::Log.severity_from_number(3).should eq OpenTelemetry::Log::Level::Trace3
    OpenTelemetry::Log.severity_from_number(4).should eq OpenTelemetry::Log::Level::Trace4
    OpenTelemetry::Log.severity_from_number(5).should eq OpenTelemetry::Log::Level::Debug
    OpenTelemetry::Log.severity_from_number(6).should eq OpenTelemetry::Log::Level::Debug2
    OpenTelemetry::Log.severity_from_number(7).should eq OpenTelemetry::Log::Level::Debug3
    OpenTelemetry::Log.severity_from_number(8).should eq OpenTelemetry::Log::Level::Debug4
    OpenTelemetry::Log.severity_from_number(9).should eq OpenTelemetry::Log::Level::Info
    OpenTelemetry::Log.severity_from_number(10).should eq OpenTelemetry::Log::Level::Info2
    OpenTelemetry::Log.severity_from_number(11).should eq OpenTelemetry::Log::Level::Info3
    OpenTelemetry::Log.severity_from_number(12).should eq OpenTelemetry::Log::Level::Info4
    OpenTelemetry::Log.severity_from_number(13).should eq OpenTelemetry::Log::Level::Warn
    OpenTelemetry::Log.severity_from_number(14).should eq OpenTelemetry::Log::Level::Warn2
    OpenTelemetry::Log.severity_from_number(15).should eq OpenTelemetry::Log::Level::Warn3
    OpenTelemetry::Log.severity_from_number(16).should eq OpenTelemetry::Log::Level::Warn4
    OpenTelemetry::Log.severity_from_number(17).should eq OpenTelemetry::Log::Level::Error
    OpenTelemetry::Log.severity_from_number(18).should eq OpenTelemetry::Log::Level::Error2
    OpenTelemetry::Log.severity_from_number(19).should eq OpenTelemetry::Log::Level::Error3
    OpenTelemetry::Log.severity_from_number(20).should eq OpenTelemetry::Log::Level::Error4
    OpenTelemetry::Log.severity_from_number(21).should eq OpenTelemetry::Log::Level::Fatal
    OpenTelemetry::Log.severity_from_number(22).should eq OpenTelemetry::Log::Level::Fatal2
    OpenTelemetry::Log.severity_from_number(23).should eq OpenTelemetry::Log::Level::Fatal3
    OpenTelemetry::Log.severity_from_number(24).should eq OpenTelemetry::Log::Level::Fatal4

    expect_raises(Exception) do
      OpenTelemetry::Log.severity_from_number(25)
    end
    expect_raises(Exception) do
      OpenTelemetry::Log.severity_from_number(0)
    end
  end

  it "can transform a severity label into a severity number" do
    OpenTelemetry::Log.severity_from_name("TRACE").should eq OpenTelemetry::Log::Level::Trace
    OpenTelemetry::Log.severity_from_name("TRACE2").should eq OpenTelemetry::Log::Level::Trace2
    OpenTelemetry::Log.severity_from_name("TRACE3").should eq OpenTelemetry::Log::Level::Trace3
    OpenTelemetry::Log.severity_from_name("TRACE4").should eq OpenTelemetry::Log::Level::Trace4
    OpenTelemetry::Log.severity_from_name("DEBUG").should eq OpenTelemetry::Log::Level::Debug
    OpenTelemetry::Log.severity_from_name("DEBUG2").should eq OpenTelemetry::Log::Level::Debug2
    OpenTelemetry::Log.severity_from_name("DEBUG3").should eq OpenTelemetry::Log::Level::Debug3
    OpenTelemetry::Log.severity_from_name("DEBUG4").should eq OpenTelemetry::Log::Level::Debug4
    OpenTelemetry::Log.severity_from_name("INFO").should eq OpenTelemetry::Log::Level::Info
    OpenTelemetry::Log.severity_from_name("INFO2").should eq OpenTelemetry::Log::Level::Info2
    OpenTelemetry::Log.severity_from_name("INFO3").should eq OpenTelemetry::Log::Level::Info3
    OpenTelemetry::Log.severity_from_name("INFO4").should eq OpenTelemetry::Log::Level::Info4
    OpenTelemetry::Log.severity_from_name("WARN").should eq OpenTelemetry::Log::Level::Warn
    OpenTelemetry::Log.severity_from_name("WARN2").should eq OpenTelemetry::Log::Level::Warn2
    OpenTelemetry::Log.severity_from_name("WARN3").should eq OpenTelemetry::Log::Level::Warn3
    OpenTelemetry::Log.severity_from_name("WARN4").should eq OpenTelemetry::Log::Level::Warn4
    OpenTelemetry::Log.severity_from_name("ERROR").should eq OpenTelemetry::Log::Level::Error
    OpenTelemetry::Log.severity_from_name("ERROR2").should eq OpenTelemetry::Log::Level::Error2
    OpenTelemetry::Log.severity_from_name("ERROR3").should eq OpenTelemetry::Log::Level::Error3
    OpenTelemetry::Log.severity_from_name("ERROR4").should eq OpenTelemetry::Log::Level::Error4
    OpenTelemetry::Log.severity_from_name("FATAL").should eq OpenTelemetry::Log::Level::Fatal
    OpenTelemetry::Log.severity_from_name("FATAL2").should eq OpenTelemetry::Log::Level::Fatal2
    OpenTelemetry::Log.severity_from_name("FATAL3").should eq OpenTelemetry::Log::Level::Fatal3
    OpenTelemetry::Log.severity_from_name("FATAL4").should eq OpenTelemetry::Log::Level::Fatal4
  end

  it "can generate Log records" do
    log = OpenTelemetry::Log.new

    log.message.should eq ""
    log.severity.should eq OpenTelemetry::Log::Level::Unspecified
    log.timestamp.should be < Time.utc
    log.observed_timestamp.should eq log.timestamp
    log.exporter.should be_nil
    log.trace_id.should be_nil
    log.span_id.should be_nil

    log = OpenTelemetry::Log.new(message: "Hello World")
    log.message.should eq "Hello World"

    log = OpenTelemetry::Log.new(
      message: "Hello World 2",
      severity: OpenTelemetry::Log::Level::Debug)
    log.message.should eq "Hello World 2"
    log.severity.should eq OpenTelemetry::Log::Level::Debug

    log = OpenTelemetry::Log.new(
      message: "Hello World 3",
      severity: OpenTelemetry::Log::Level::Debug2,
      timestamp: Time.utc(2020, 1, 1, 12, 0, 0))

    log.message.should eq "Hello World 3"
    log.severity.should eq OpenTelemetry::Log::Level::Debug2
    log.timestamp.should eq Time.utc(2020, 1, 1, 12, 0, 0)
    log.observed_timestamp.should eq log.timestamp

    log = OpenTelemetry::Log.new(
      message: "Hello World 4",
      severity: 17,
      timestamp: Time.utc(2020, 1, 1, 12, 0, 0),
      trace_id: "0123456701234567".to_slice,
      span_id: "01234567".to_slice)

    log.message.should eq "Hello World 4"
    log.severity.should eq OpenTelemetry::Log::Level::Error
    log.timestamp.should eq Time.utc(2020, 1, 1, 12, 0, 0)
    log.observed_timestamp.should eq log.timestamp
    log.trace_id.should eq "0123456701234567".to_slice
    log.span_id.should eq "01234567".to_slice

    log = OpenTelemetry::Log.new(
      message: "Goodbye Cruel World",
      severity: OpenTelemetry::Log::Level::Fatal,
      timestamp: Time.utc(2022, 1, 1, 12, 1, 1),
      observed_timestamp: Time.utc(2022, 1, 1, 12, 0, 0),
      trace_id: "0123456701234567".to_slice,
      span_id: "01234567".to_slice)

    log.message.should eq "Goodbye Cruel World"
    log.severity.should eq OpenTelemetry::Log::Level::Fatal
    log.timestamp.should eq Time.utc(2022, 1, 1, 12, 1, 1)
    log.observed_timestamp.should eq Time.utc(2022, 1, 1, 12, 0, 0)
    log.trace_id.should eq "0123456701234567".to_slice
    log.span_id.should eq "01234567".to_slice
  end
end

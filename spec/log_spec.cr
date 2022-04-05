require "./spec_helper"

describe OpenTelemetry::LogRecord do
  it "can transform a severity number into a severity label" do
    OpenTelemetry::LogRecord.severity_from_number(1).should eq OpenTelemetry::LogRecord::Level::Trace
    OpenTelemetry::LogRecord.severity_from_number(2).should eq OpenTelemetry::LogRecord::Level::Trace2
    OpenTelemetry::LogRecord.severity_from_number(3).should eq OpenTelemetry::LogRecord::Level::Trace3
    OpenTelemetry::LogRecord.severity_from_number(4).should eq OpenTelemetry::LogRecord::Level::Trace4
    OpenTelemetry::LogRecord.severity_from_number(5).should eq OpenTelemetry::LogRecord::Level::Debug
    OpenTelemetry::LogRecord.severity_from_number(6).should eq OpenTelemetry::LogRecord::Level::Debug2
    OpenTelemetry::LogRecord.severity_from_number(7).should eq OpenTelemetry::LogRecord::Level::Debug3
    OpenTelemetry::LogRecord.severity_from_number(8).should eq OpenTelemetry::LogRecord::Level::Debug4
    OpenTelemetry::LogRecord.severity_from_number(9).should eq OpenTelemetry::LogRecord::Level::Info
    OpenTelemetry::LogRecord.severity_from_number(10).should eq OpenTelemetry::LogRecord::Level::Info2
    OpenTelemetry::LogRecord.severity_from_number(11).should eq OpenTelemetry::LogRecord::Level::Info3
    OpenTelemetry::LogRecord.severity_from_number(12).should eq OpenTelemetry::LogRecord::Level::Info4
    OpenTelemetry::LogRecord.severity_from_number(13).should eq OpenTelemetry::LogRecord::Level::Warn
    OpenTelemetry::LogRecord.severity_from_number(14).should eq OpenTelemetry::LogRecord::Level::Warn2
    OpenTelemetry::LogRecord.severity_from_number(15).should eq OpenTelemetry::LogRecord::Level::Warn3
    OpenTelemetry::LogRecord.severity_from_number(16).should eq OpenTelemetry::LogRecord::Level::Warn4
    OpenTelemetry::LogRecord.severity_from_number(17).should eq OpenTelemetry::LogRecord::Level::Error
    OpenTelemetry::LogRecord.severity_from_number(18).should eq OpenTelemetry::LogRecord::Level::Error2
    OpenTelemetry::LogRecord.severity_from_number(19).should eq OpenTelemetry::LogRecord::Level::Error3
    OpenTelemetry::LogRecord.severity_from_number(20).should eq OpenTelemetry::LogRecord::Level::Error4
    OpenTelemetry::LogRecord.severity_from_number(21).should eq OpenTelemetry::LogRecord::Level::Fatal
    OpenTelemetry::LogRecord.severity_from_number(22).should eq OpenTelemetry::LogRecord::Level::Fatal2
    OpenTelemetry::LogRecord.severity_from_number(23).should eq OpenTelemetry::LogRecord::Level::Fatal3
    OpenTelemetry::LogRecord.severity_from_number(24).should eq OpenTelemetry::LogRecord::Level::Fatal4

    expect_raises(Exception) do
      OpenTelemetry::LogRecord.severity_from_number(25)
    end
    expect_raises(Exception) do
      OpenTelemetry::LogRecord.severity_from_number(0)
    end
  end

  it "can transform a severity label into a severity number" do
    OpenTelemetry::LogRecord.severity_from_name("TRACE").should eq OpenTelemetry::LogRecord::Level::Trace
    OpenTelemetry::LogRecord.severity_from_name("TRACE2").should eq OpenTelemetry::LogRecord::Level::Trace2
    OpenTelemetry::LogRecord.severity_from_name("TRACE3").should eq OpenTelemetry::LogRecord::Level::Trace3
    OpenTelemetry::LogRecord.severity_from_name("TRACE4").should eq OpenTelemetry::LogRecord::Level::Trace4
    OpenTelemetry::LogRecord.severity_from_name("DEBUG").should eq OpenTelemetry::LogRecord::Level::Debug
    OpenTelemetry::LogRecord.severity_from_name("DEBUG2").should eq OpenTelemetry::LogRecord::Level::Debug2
    OpenTelemetry::LogRecord.severity_from_name("DEBUG3").should eq OpenTelemetry::LogRecord::Level::Debug3
    OpenTelemetry::LogRecord.severity_from_name("DEBUG4").should eq OpenTelemetry::LogRecord::Level::Debug4
    OpenTelemetry::LogRecord.severity_from_name("INFO").should eq OpenTelemetry::LogRecord::Level::Info
    OpenTelemetry::LogRecord.severity_from_name("INFO2").should eq OpenTelemetry::LogRecord::Level::Info2
    OpenTelemetry::LogRecord.severity_from_name("INFO3").should eq OpenTelemetry::LogRecord::Level::Info3
    OpenTelemetry::LogRecord.severity_from_name("INFO4").should eq OpenTelemetry::LogRecord::Level::Info4
    OpenTelemetry::LogRecord.severity_from_name("WARN").should eq OpenTelemetry::LogRecord::Level::Warn
    OpenTelemetry::LogRecord.severity_from_name("WARN2").should eq OpenTelemetry::LogRecord::Level::Warn2
    OpenTelemetry::LogRecord.severity_from_name("WARN3").should eq OpenTelemetry::LogRecord::Level::Warn3
    OpenTelemetry::LogRecord.severity_from_name("WARN4").should eq OpenTelemetry::LogRecord::Level::Warn4
    OpenTelemetry::LogRecord.severity_from_name("ERROR").should eq OpenTelemetry::LogRecord::Level::Error
    OpenTelemetry::LogRecord.severity_from_name("ERROR2").should eq OpenTelemetry::LogRecord::Level::Error2
    OpenTelemetry::LogRecord.severity_from_name("ERROR3").should eq OpenTelemetry::LogRecord::Level::Error3
    OpenTelemetry::LogRecord.severity_from_name("ERROR4").should eq OpenTelemetry::LogRecord::Level::Error4
    OpenTelemetry::LogRecord.severity_from_name("FATAL").should eq OpenTelemetry::LogRecord::Level::Fatal
    OpenTelemetry::LogRecord.severity_from_name("FATAL2").should eq OpenTelemetry::LogRecord::Level::Fatal2
    OpenTelemetry::LogRecord.severity_from_name("FATAL3").should eq OpenTelemetry::LogRecord::Level::Fatal3
    OpenTelemetry::LogRecord.severity_from_name("FATAL4").should eq OpenTelemetry::LogRecord::Level::Fatal4
  end

  it "can generate Log records" do
    log = OpenTelemetry::LogRecord.new

    log.body.should be_nil
    log.severity.should eq OpenTelemetry::LogRecord::Level::Unspecified
    log.time.should be_nil

    log.observed_time.should eq log.time
    log.exporter.should be_nil
    log.trace_id.should be_nil
    log.span_id.should be_nil

    log = OpenTelemetry::LogRecord.new(body: "Hello World")
    log.body.should eq "Hello World"

    log = OpenTelemetry::LogRecord.new(
      body: "Hello World 2",
      severity: OpenTelemetry::LogRecord::Level::Debug)

    log.body.should eq "Hello World 2"
    log.severity.should eq OpenTelemetry::LogRecord::Level::Debug

    log = OpenTelemetry::LogRecord.new(
      body: "Hello World 3",
      severity: OpenTelemetry::LogRecord::Level::Debug2,
      time: Time.utc(2020, 1, 1, 12, 0, 0))

    log.body.should eq "Hello World 3"
    log.severity.should eq OpenTelemetry::LogRecord::Level::Debug2
    log.time.should eq Time.utc(2020, 1, 1, 12, 0, 0)
    log.observed_time.should eq log.time

    log = OpenTelemetry::LogRecord.new(
      body: "Hello World 4",
      severity: 17,
      time: Time.utc(2020, 1, 1, 12, 0, 0),
      trace_id: "0123456701234567".to_slice,
      span_id: "01234567".to_slice)

    log.body.should eq "Hello World 4"
    log.severity.should eq OpenTelemetry::LogRecord::Level::Error
    log.time.should eq Time.utc(2020, 1, 1, 12, 0, 0)
    log.observed_time.should eq log.time
    log.trace_id.should eq "0123456701234567".to_slice
    log.span_id.should eq "01234567".to_slice

    log = OpenTelemetry::LogRecord.new(
      body: "Goodbye Cruel World",
      severity: OpenTelemetry::LogRecord::Level::Fatal,
      time: Time.utc(2022, 1, 1, 12, 1, 1),
      observed_time: Time.utc(2022, 1, 1, 12, 0, 0),
      trace_id: "0123456701234567".to_slice,
      span_id: "01234567".to_slice)

    log.body.should eq "Goodbye Cruel World"
    log.severity.should eq OpenTelemetry::LogRecord::Level::Fatal
    log.time.should eq Time.utc(2022, 1, 1, 12, 1, 1)
    log.observed_time.should eq Time.utc(2022, 1, 1, 12, 0, 0)
    log.trace_id.should eq "0123456701234567".to_slice
    log.span_id.should eq "01234567".to_slice
  end

  it "can generate properly formed JSON versions of a log record" do
    OpenTelemetry::LogRecord.new(
      body: "Goodbye Cruel World",
      severity: OpenTelemetry::LogRecord::Level::Fatal,
      time: Time.utc(2022, 1, 1, 12, 1, 1),
      observed_time: Time.utc(2022, 1, 1, 12, 0, 0),
      trace_id: "0123456701234567".to_slice,
      span_id: "01234567".to_slice)
  end
end

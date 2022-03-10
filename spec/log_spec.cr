require "./spec_helper"

describe OpenTelemetry::Log do
  it "can transform a severity number into a severity label" do
    OpenTelemetry::Log.severity_name_from_number(1).should eq "TRACE"
    OpenTelemetry::Log.severity_name_from_number(2).should eq "TRACE2"
    OpenTelemetry::Log.severity_name_from_number(3).should eq "TRACE3"
    OpenTelemetry::Log.severity_name_from_number(4).should eq "TRACE4"
    OpenTelemetry::Log.severity_name_from_number(5).should eq "DEBUG"
    OpenTelemetry::Log.severity_name_from_number(6).should eq "DEBUG2"
    OpenTelemetry::Log.severity_name_from_number(7).should eq "DEBUG3"
    OpenTelemetry::Log.severity_name_from_number(8).should eq "DEBUG4"
    OpenTelemetry::Log.severity_name_from_number(9).should eq "INFO"
    OpenTelemetry::Log.severity_name_from_number(10).should eq "INFO2"
    OpenTelemetry::Log.severity_name_from_number(11).should eq "INFO3"
    OpenTelemetry::Log.severity_name_from_number(12).should eq "INFO4"
    OpenTelemetry::Log.severity_name_from_number(13).should eq "WARN"
    OpenTelemetry::Log.severity_name_from_number(14).should eq "WARN2"
    OpenTelemetry::Log.severity_name_from_number(15).should eq "WARN3"
    OpenTelemetry::Log.severity_name_from_number(16).should eq "WARN4"
    OpenTelemetry::Log.severity_name_from_number(17).should eq "ERROR"
    OpenTelemetry::Log.severity_name_from_number(18).should eq "ERROR2"
    OpenTelemetry::Log.severity_name_from_number(19).should eq "ERROR3"
    OpenTelemetry::Log.severity_name_from_number(20).should eq "ERROR4"
    OpenTelemetry::Log.severity_name_from_number(21).should eq "FATAL"
    OpenTelemetry::Log.severity_name_from_number(22).should eq "FATAL2"
    OpenTelemetry::Log.severity_name_from_number(23).should eq "FATAL3"
    OpenTelemetry::Log.severity_name_from_number(24).should eq "FATAL4"
    expect_raises(Exception) do
      OpenTelemetry::Log.severity_name_from_number(25)
    end
    expect_raises(Exception) do
      OpenTelemetry::Log.severity_name_from_number(0)
    end
  end

  it "can transform a severity label into a severity number" do
    OpenTelemetry::Log.severity_number_from_name("TRACE").should eq 1
    OpenTelemetry::Log.severity_number_from_name("TRACE2").should eq 2
    OpenTelemetry::Log.severity_number_from_name("TRACE3").should eq 3
    OpenTelemetry::Log.severity_number_from_name("TRACE4").should eq 4
    OpenTelemetry::Log.severity_number_from_name("DEBUG").should eq 5
    OpenTelemetry::Log.severity_number_from_name("DEBUG2").should eq 6
    OpenTelemetry::Log.severity_number_from_name("DEBUG3").should eq 7
    OpenTelemetry::Log.severity_number_from_name("DEBUG4").should eq 8
    OpenTelemetry::Log.severity_number_from_name("INFO").should eq 9
    OpenTelemetry::Log.severity_number_from_name("INFO2").should eq 10
    OpenTelemetry::Log.severity_number_from_name("INFO3").should eq 11
    OpenTelemetry::Log.severity_number_from_name("INFO4").should eq 12
    OpenTelemetry::Log.severity_number_from_name("WARN").should eq 13
    OpenTelemetry::Log.severity_number_from_name("WARN2").should eq 14
    OpenTelemetry::Log.severity_number_from_name("WARN3").should eq 15
    OpenTelemetry::Log.severity_number_from_name("WARN4").should eq 16
    OpenTelemetry::Log.severity_number_from_name("ERROR").should eq 17
    OpenTelemetry::Log.severity_number_from_name("ERROR2").should eq 18
    OpenTelemetry::Log.severity_number_from_name("ERROR3").should eq 19
    OpenTelemetry::Log.severity_number_from_name("ERROR4").should eq 20
    OpenTelemetry::Log.severity_number_from_name("FATAL").should eq 21
    OpenTelemetry::Log.severity_number_from_name("FATAL2").should eq 22
    OpenTelemetry::Log.severity_number_from_name("FATAL3").should eq 23
    OpenTelemetry::Log.severity_number_from_name("FATAL4").should eq 24
  end

  it "can generate Log records" do
    log = OpenTelemetry::Log.new

    log.message.should eq ""
    log.severity.should eq OpenTelemetry::Log::Level::Info
    log.timestamp.should be < Time.utc
    log.observed_timestamp.should eq log.timestamp
    log.exporter.should be_nil
    log.trace_id.should be_nil
    log.span_id.should be_nil

    log = OpenTelemetry::Log.new(message: "Hello World")
    log.message.should eq "Hello World"

    log = OpenTelemetry::Log.new(message: "Hello World", severity: OpenTelemetry::Log::Level::Debug)
    log.message.should eq "Hello World"
    log.severity.should eq OpenTelemetry::Log::Level::Debug

    log = OpenTelemetry::Log.new(message: "Hello World", severity: OpenTelemetry::Log::Level::Debug, timestamp: Time.utc(2020, 1, 1, 12, 0, 0))
  end
end

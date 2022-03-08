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
  end
end

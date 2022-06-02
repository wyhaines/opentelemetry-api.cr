require "./spec_helper"

describe OpenTelemetry do
  before_each do
    # Ensure that global state is always reset to a known starting point
    # before each spec runs.
    OpenTelemetry.configure do |config|
      config.service_name = "my_app_or_library"
      config.service_version = "1.1.1"
      config.exporter = OpenTelemetry::Exporter.new
    end
  end

  it "default configuration is setup as expected" do
    OpenTelemetry.config.service_name.should eq "my_app_or_library"
    OpenTelemetry.config.service_version.should eq "1.1.1"
    OpenTelemetry.config.exporter.should be_a OpenTelemetry::Exporter
  end

  it "can create a trace with arguments passed to the class method" do
    trace = OpenTelemetry.trace_provider(
      "my_app_or_library",
      "1.2.3",
      OpenTelemetry::Exporter.new).trace

    trace.service_name.should eq "my_app_or_library"
    trace.service_version.should eq "1.2.3"
    trace.exporter.should be_a OpenTelemetry::Exporter
  end

  it "substitutes the global provider configuration when values are not provided via method argument initialization" do
    trace = OpenTelemetry.trace_provider("my_app_or_library2").trace
    trace.service_name.should eq "my_app_or_library2"
    trace.service_version.should eq "1.1.1"
    trace.exporter.should be_a OpenTelemetry::Exporter
  end

  it "only creates a new TraceProvider when needed" do
    tp1 = OpenTelemetry.trace_provider
    tp2 = OpenTelemetry.trace_provider
    tp3 = OpenTelemetry.trace_provider("beat of my own drum")
    tp4 = OpenTelemetry.trace_provider
    tp1.should eq tp2
    tp1.should_not eq tp3
    tp3.should eq tp4
  end

  it "can create a trace via a block passed to the class method" do
    trace = OpenTelemetry.trace_provider do |t|
      t.service_name = "my_app_or_library"
      t.service_version = "1.2.3"
      t.exporter = OpenTelemetry::Exporter.new
    end.trace

    trace.service_name.should eq "my_app_or_library"
    trace.service_version.should eq "1.2.3"
    trace.exporter.should be_a OpenTelemetry::Exporter
  end

  it "substitutes the global provider configuration when values are not set via block initialization" do
    trace = OpenTelemetry.trace_provider do |t|
      t.service_version = "2.2.2"
    end.trace

    trace.service_name.should eq "my_app_or_library"
    trace.service_version.should eq "2.2.2"
    trace.exporter.should be_a OpenTelemetry::Exporter
  end
end

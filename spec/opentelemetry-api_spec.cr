require "./spec_helper"

describe OpenTelemetry do
  before_each do
    # Ensure that global state is always reset to a known starting point
    # before each spec runs.
    OpenTelemetry.configure do |config|
      config.service_name = "my_app_or_library"
      config.service_version = "1.1.1"
      config.exporter = TestExporter.new
    end
  end

  it "default configuration is setup as expected" do
    OpenTelemetry.config.service_name.should eq "my_app_or_library"
    OpenTelemetry.config.service_version.should eq "1.1.1"
    OpenTelemetry.config.exporter.should be_a TestExporter
  end

  it "can create a trace with arguments passed to the class method" do
    trace = OpenTelemetry.trace_provider(
      "my_app_or_library",
      "1.2.3",
      OpenTelemetry::Exporter::Null.new)

    trace.service_name.should eq "my_app_or_library"
    trace.service_version.should eq "1.2.3"
    trace.exporter.should be_a OpenTelemetry::Exporter::Null
  end

  it "substitutes the global provider configuration when values are not provided via method argument initialization" do
    trace = OpenTelemetry.trace_provider("my_app_or_library2")
    trace.service_name.should eq "my_app_or_library2"
    trace.service_version.should eq "1.1.1"
    trace.exporter.should be_a TestExporter
  end

  it "can create a trace via a block passed to the class method" do
    trace = OpenTelemetry.trace_provider do |t|
      t.service_name = "my_app_or_library"
      t.service_version = "1.2.3"
      t.exporter = OpenTelemetry::Exporter::Null.new
    end

    trace.service_name.should eq "my_app_or_library"
    trace.service_version.should eq "1.2.3"
    trace.exporter.should be_a OpenTelemetry::Exporter::Null
  end

  it "substitutes the global provider configuration when values are not set via block initialization" do
    trace = OpenTelemetry.trace_provider do |t|
      t.service_version = "2.2.2"
    end

    trace.service_name.should eq "my_app_or_library"
    trace.service_version.should eq "2.2.2"
    trace.exporter.should be_a TestExporter
  end
end

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

  it "can create a tracer with arguments passed to the class method" do
    tracer = OpenTelemetry.tracer_provider(
      "my_app_or_library",
      "1.2.3",
      OpenTelemetry::NullExporter.new)

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "1.2.3"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "substitutes the global provider configuration when values are not provided via method argument initialization" do
    tracer = OpenTelemetry.tracer_provider("my_app_or_library2")
    tracer.service_name.should eq "my_app_or_library2"
    tracer.service_version.should eq "1.1.1"
    tracer.exporter.should be_a TestExporter
  end

  it "can create a tracer via a block passed to the class method" do
    tracer = OpenTelemetry.tracer_provider do |t|
      t.service_name = "my_app_or_library"
      t.service_version = "1.2.3"
      t.exporter = OpenTelemetry::NullExporter.new
    end

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "1.2.3"
    tracer.exporter.should be_a OpenTelemetry::NullExporter
  end

  it "substitutes the global provider configuration when values are not set via block initialization" do
    tracer = OpenTelemetry.tracer_provider do |t|
      t.service_version = "2.2.2"
    end

    tracer.service_name.should eq "my_app_or_library"
    tracer.service_version.should eq "2.2.2"
    tracer.exporter.should be_a TestExporter
  end
end

require "./spec_helper"

describe OpenTelemetry::Exporter::Http, tags: ["Exporter::Http"] do
  it "can directly initialize the endpoint with a string" do
    uri = "http://localhost:4318/v1/traces"
    exporter = OpenTelemetry::Exporter::Http.new(uri)
    exporter.endpoint.to_s.should eq uri
  end

  it "can directly initialize the endpoint with a URI" do
    uri = URI.parse("http://localhost:4318/v1/traces")
    exporter = OpenTelemetry::Exporter::Http.new(uri)
    exporter.endpoint.to_s.should eq uri.to_s
  end

  it "can use block initialization and initialize the endpoint with a string" do
    uri = "http://localhost:4318/v1/traces"
    exporter = OpenTelemetry::Exporter::Http.new do |e|
      e.endpoint = uri
    end
    exporter.endpoint.to_s.should eq uri
  end

  it "can use block initialization and initialize the endpoint with a URI" do
    uri = URI.parse("http://localhost:4318/v1/traces")
    exporter = OpenTelemetry::Exporter::Http.new do |e|
      e.endpoint = uri
    end
    exporter.endpoint.to_s.should eq uri.to_s
  end

  it "sets up the tracing export location correctly, if given a string URL that lacks it" do
    uri = "http://localhost:4318"
    exporter = OpenTelemetry::Exporter::Http.new(uri)
    exporter.endpoint.to_s.should eq "http://localhost:4318/v1/traces"
  end

  it "sets up the tracing export location correctly, if given a string URI that lacks it" do
    uri = URI.parse("http://localhost:4318")
    exporter = OpenTelemetry::Exporter::Http.new(uri)
    exporter.endpoint.to_s.should eq "http://localhost:4318/v1/traces"
  end
end

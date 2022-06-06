require "../spec_helper"

describe OpenTelemetry::Exporter::Http do
  it "initialize with endpoint argument" do
    OpenTelemetry::Exporter::Http.new(endpoint: "http://localhost:4318/v1/traces")
  end
end

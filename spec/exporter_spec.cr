require "./spec_helper"
require "json"

describe OpenTelemetry::Exporter do
  it "can export to an IO::Memory" do
    memory = IO::Memory.new

    original_config = OpenTelemetry.config
    OpenTelemetry.configure do |config|
      config.exporter = OpenTelemetry::Exporter.new(variant: :io, io: memory)
    end
    trace = OpenTelemetry.trace
    trace.provider.exporter.try(&.exporter).should be_a OpenTelemetry::Exporter::IO
    trace.in_span("IO Memory Exporter Test") do |span|
      span.set_attribute("key", "value")
    end

    memory.rewind
    json = memory.gets_to_end
    pjson = JSON.parse(json)
    pjson["spans"].as_a.size.should eq 1
    pjson["spans"][0]["name"].as_s.should eq "IO Memory Exporter Test"
    OpenTelemetry.config = original_config
  end
end

require "./provider"
require "./meter"

module OpenTelemetry
  # A MeterProvider encapsulates a set of meter configuration, and provides an interface for creating Meter instances.
  class MeterProvider < Provider
    def meter
      new_meter = Meter.new
      new_meter.provider = self

      new_meter
    end

    def meter(
      service_name = nil,
      service_version = nil,
      schema_url = nil,
      exporter = nil,
      interval = nil
    )
      new_meter = Meter.new(
        service_name: service_name,
        service_version: service_version,
        schema_url: schema_url,
        exporter: exporter,
        interval: interval
      )
      new_meter.merge_configuration_from_provider = self

      new_meter
    end

    def meter
      new_meter = meter
      new_meter.provider = self
      yield new_meter

      new_meter
    end
  end
end

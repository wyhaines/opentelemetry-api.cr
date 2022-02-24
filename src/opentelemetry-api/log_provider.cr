require "./provider"
require "./log"

module OpenTelemetry
  class LogProvider < Provider
    def log
      new_log = Log.new
      new_log.provider = self

      new_log
    end

    def log(
      service_name = nil,
      service_version = nil,
      schema_url = nil,
      exporter = nil
    )
      new_log = Log.new(
        service_name,
        service_version,
        schema_url,
        exporter)
      new_log.merge_configuration_from_provider = self

      new_log
    end

    def log
      new_log = log
      new_log.provider = self
      yield new_log

      new_log
    end
  end
end

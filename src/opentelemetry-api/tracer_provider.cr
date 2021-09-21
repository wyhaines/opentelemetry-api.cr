require "./tracer_provider/configuration"
require "./tracer"

module OpenTelemetry
  # A TracerProvider encapsulates a set of tracing configuration, and provides an interface for creating Trace instances.
  class TracerProvider
    getter config : Configuration

    def initialize
      @config = Configuration::Factory.build
    end

    def initialize(&block : Configuration::Factory ->)
      @config = Configuration::Factory.build do |config_block|
        block.call(config_block)
      end
    end

    def initialize(
      service_name : String,
      service_version : String = "",
      exporter : Exporter = NullExporter.new
    )
      @config = Configuration.new(
        service_name: service_name,
        service_version: service_version,
        exporter: exporter)
    end

    def configure!(new_config)
      @config = new_config.dup

      self
    end

    def configure(new_config)
      @config = Configuration::Factory.build(new_config) do |cfg|
        cfg.service_name = @config.service_name.empty? ? new_config.service_name : @config.service_name
        cfg.service_version = @config.service_version.empty? ? new_config.service_version : @config.service_version
        cfg.exporter = @config.exporter.nil? || @config.exporter.is_a?(NullExporter) ? new_config.exporter : @config.exporter
      end

      self
    end

    def tracer
      new_trace = Tracer.new
      new_trace.provider = self

      new_trace
    end

    def service_name
      @config.service_name
    end

    def service_version
      @config.service_version
    end

    def exporter
      @config.exporter
    end
  end
end

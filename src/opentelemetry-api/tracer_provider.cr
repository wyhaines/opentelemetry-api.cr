require "./tracer_provider/configuration"
require "./context"
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
      service_name : String = "",
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

    def merge_configuration(secondary_config)
      @config = Configuration::Factory.build(@config) do |cfg|
        cfg.service_name = secondary_config.service_name if cfg.service_name.empty? || cfg.service_name =~ /service_[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}/
        cfg.service_version = secondary_config.service_version if cfg.service_version.empty?
        cfg.exporter = secondary_config.exporter if cfg.exporter.nil? || cfg.exporter.is_a?(AbstractExporter)
      end

      self
    end

    def tracer
      new_tracer = Tracer.new
      new_tracer.provider = self

      new_trace
    end

    def tracer(
      service_name = nil,
      service_version = nil,
      exporter = nil
    )
      new_tracer = Tracer.new(service_name, service_version, exporter)
      new_tracer.merge_configuration_from_provider = self

      new_tracer
    end

    def tracer
      new_tracer = tracer
      new_tracer.provider = self
      yield new_tracer

      new_tracer
    end

    def service_name
      @config.service_name
    end

    def service_name=(val)
      @config = Configuration::Factory.build(@config) do |cfg|
        cfg.service_name = val
      end
    end

    def service_version=(val)
      @config = Configuration::Factory.build(@config) do |cfg|
        cfg.service_version = val
      end
    end

    def service_version
      @config.service_version
    end

    def exporter
      @config.exporter
    end

    def exporter=(val)
      @config = Configuration::Factory.build(@config) do |cfg|
        cfg.exporter = val
      end
    end
  end
end

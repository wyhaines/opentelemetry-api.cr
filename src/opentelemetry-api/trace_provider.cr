require "./trace_provider/configuration"
require "./id_generator"
require "./context"
require "./trace"

module OpenTelemetry
  # A TraceProvider encapsulates a set of tracing configuration, and provides an interface for creating Trace instances.
  class TraceProvider
    getter config : Configuration
    @id_generator_instance : IdGenerator::Base?

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
      exporter : Exporter = Exporter.new(:null),
      id_generator = "unique"
    )
      @config = Configuration.new(
        service_name: service_name,
        service_version: service_version,
        exporter: exporter,
        id_generator: id_generator)
    end

    def configure!(new_config)
      @config = new_config.dup

      self
    end

    def merge_configuration(secondary_config)
      @config = Configuration::Factory.build(@config) do |cfg|
        cfg.service_name = secondary_config.service_name if cfg.service_name.empty? || cfg.service_name =~ /service_[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}/
        cfg.service_version = secondary_config.service_version if cfg.service_version.empty?
        cfg.exporter = secondary_config.exporter if cfg.exporter.nil? || cfg.exporter.exporter.is_a?(Exporter::Abstract)
        cfg.id_generator = secondary_config.id_generator if cfg.id_generator.nil? || cfg.id_generator.generator.is_a?(AbstractIdGenerator)
      end

      self
    end

    def trace
      new_trace = Trace.new
      new_trace.provider = self

      new_trace
    end

    def trace(
      service_name = nil,
      service_version = nil,
      exporter = nil,
      id_generator = nil
    )
      new_trace = Trace.new(service_name, service_version, exporter, id_generator)
      new_trace.merge_configuration_from_provider = self

      new_trace
    end

    def trace
      new_trace = trace
      new_trace.provider = self
      yield new_trace

      new_trace
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

    def id_generator
      @config.id_generator
    end

    def id_generator=(val)
      @config = Configuration::Factory.build(@config) do |cfg|
        cfg.id_generator = val
      end
    end
  end
end

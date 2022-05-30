require "./provider/configuration"
require "./id_generator"
require "./context"

module OpenTelemetry
  # Provider is an abstract superclass of other specific providers, such as the TraceProvider
  # or the MetricsProvider. It supplies some common faculties for dealing with configuration.
  abstract class Provider
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

    def initialize(config, &block : Configuration::Factory ->)
      @config = Configuration::Factory.build(config) do |config_block|
        block.call(config_block)
      end
    end

    def initialize(
      service_name : String = "",
      service_version : String = "",
      schema_url : String = "",
      exporter : Exporter? = nil,
      sampler : Sampler = Sampler::AlwaysOn.new,
      id_generator = "unique"
    )
      @config = Configuration.new(
        service_name: service_name,
        service_version: service_version,
        schema_url: schema_url,
        exporter: exporter,
        sampler: sampler,
        id_generator: id_generator)
    end

    def configure!(new_config)
      @config = new_config.dup

      self
    end

    def merge_configuration(secondary_config)
      @config = Configuration::Factory.build(@config) do |cfg|
        merge_service_name(cfg, secondary_config)
        merge_service_version(cfg, secondary_config)
        merge_schema_url(cfg, secondary_config)
        merge_exporter(cfg, secondary_config)
        merge_sampler(cfg, secondary_config)
        merge_id_generator(cfg, secondary_config)
      end

      self
    end

    private def merge_service_name(config, secondary_config)
      config.service_name = secondary_config.service_name if config.service_name.empty? || config.service_name =~ /service_[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}/
    end

    private def merge_service_version(config, secondary_config)
      config.service_version = secondary_config.service_version if config.service_version.empty?
    end

    private def merge_schema_url(config, secondary_config)
      config.schema_url = secondary_config.schema_url if config.schema_url.empty?
    end

    private def merge_exporter(config, secondary_config)
      config.exporter = secondary_config.exporter if config.exporter.nil? || config.exporter.try(&.exporter).is_a?(Exporter::Abstract)
    end

    private def merge_sampler(config, secondary_config)
      config.sampler = secondary_config.sampler if config.sampler.nil? || config.sampler.is_a?(Sampler)
    end

    private def merge_id_generator(config, secondary_config)
      config.id_generator = secondary_config.id_generator if config.id_generator.nil? || config.id_generator.generator.is_a?(AbstractIdGenerator)
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

    def schema_url
      @config.schema_url
    end

    def schema_url=(val)
      @config = Configuration::Factory.build(@config) do |cfg|
        cfg.schema_url = val
      end
    end

    def exporter
      @config.exporter
    end

    def exporter=(val)
      @config = Configuration::Factory.build(@config) do |cfg|
        cfg.exporter = val
      end
    end

    def sampler
      @config.sampler
    end

    def sampler=(val)
      @config = Configuration::Factory.build(@config) do |cfg|
        cfg.sampler = val
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

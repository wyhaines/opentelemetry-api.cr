module OpenTelemetry
  # A `Configuration` is a `Struct` that is optimized to be a read-mostly data
  # structure. However, during creation of a `Configuration` instance, it can be
  # useful to have access to a read/write object for easy manipulation.
  #
  # The `OpenTelemetry::Configuration::Factory` provides this interface.
  class TraceProvider
    struct Configuration
      class Factory
        property service_name : String = ""
        property service_version : String = ""
        property exporter : Exporter? = nil
        property id_generator : IdGenerator

        # :nodoc:
        private def self._build(instance)
          Configuration.new(
            service_name: instance.service_name,
            service_version: instance.service_version,
            exporter: instance.exporter,
            id_generator: instance.id_generator
          )
        end

        def self.build(new_config : Configuration, &block : Factory ->)
          build(
            service_name: new_config.service_name,
            service_version: new_config.service_version,
            exporter: new_config.exporter,
            id_generator: new_config.id_generator
          ) do |instance|
            block.call(instance)
          end
        end

        def self.build(
          service_name = "service_#{CSUUID.unique}",
          service_version = "",
          exporter = Exporter.new(:abstract),
          id_generator = IdGenerator.new("unique")
        )
          instance = Factory.allocate
          instance.initialize(service_name, service_version, exporter, id_generator)
          yield instance
          _build(instance)
        end

        def self.build(
          service_name = "service_#{CSUUID.unique}",
          service_version = "",
          exporter = Exporter.new(:abstract),
          id_generator = IdGenerator.new("unique")
        )
          instance = Factory.allocate
          instance.initialize(service_name, service_version, exporter, id_generator)
          _build(instance)
        end

        def initialize(@service_name, @service_version, @exporter, @id_generator); end
      end
    end
  end
end

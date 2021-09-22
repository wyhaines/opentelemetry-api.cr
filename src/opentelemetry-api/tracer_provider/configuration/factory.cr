module OpenTelemetry
  # A `Configuration` is a `Struct` that is optimized to be a read-mostly data
  # structure. However, during creation of a `Configuration` instance, it can be
  # useful to have access to a read/write object for easy manipulation.
  #
  # The `OpenTelemetry::Configuration::Factory` provides this interface.
  class TracerProvider
    struct Configuration
      class Factory
        property service_name : String = ""
        property service_version : String = ""
        property exporter : Exporter = AbstractExporter.new

        # :nodoc:
        private def self._build(instance)
          Configuration.new(
            service_name: instance.service_name,
            service_version: instance.service_version,
            exporter: instance.exporter
          )
        end

        def self.build(new_config : Configuration, &block : Factory ->)
          build(
            service_name: new_config.service_name,
            service_version: new_config.service_version,
            exporter: new_config.exporter
          ) do |instance|
            block.call(instance)
          end
        end

        def self.build(
          service_name = "service_#{CSUUID.unique.to_s}",
          service_version = "",
          exporter = AbstractExporter.new
        )
          instance = Factory.allocate
          instance.initialize(service_name, service_version, exporter)
          yield instance
          _build(instance)
        end

        def self.build(
          service_name = "service_#{CSUUID.unique.to_s}",
          service_version = "",
          exporter = AbstractExporter.new
        )
          instance = Factory.allocate
          instance.initialize(service_name, service_version, exporter)
          _build(instance)
        end

        def initialize(@service_name, @service_version, @exporter); end
      end
    end
  end
end

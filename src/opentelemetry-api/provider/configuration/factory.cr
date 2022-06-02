module OpenTelemetry
  # A `Configuration` is a `Struct` that is optimized to be a read-mostly data
  # structure. However, during creation of a `Configuration` instance, it can be
  # useful to have access to a read/write object for easy manipulation.
  #
  # The `OpenTelemetry::Configuration::Factory` provides this interface.
  class Provider
    class Configuration
      def self.default_service_name
        ENV["OTEL_SERVICE_NAME"]?
      end

      def self.default_service_version
        ENV["OTEL_SERVICE_VERSION"]?
      end

      def self.default_schema_url
        ENV["OTEL_SCHEMA_URL"]?
      end

      def self.default_traces_sampler
        ENV["OTEL_TRACES_SAMPLER"]?
      end

      def self.default_traces_sampler_arg
        ENV["OTEL_TRACES_SAMPLER_ARG"]?
      end

      def self.default_traces_exporter
        ENV["OTEL_TRACES_EXPORTER"]?
      end

      # TODO: The Sampler code all feels kind of bodgey. It should be
      # revisited, though maybe that will come naturally when all of
      # the SDK code is surgically separated from the API code.
      def self.default_sampler_instance
        sampler_class_name = normalize_sampler_name(default_traces_sampler.to_s)
        sampler_class = get_sampler_class_from_name(
          sampler_class_name.split(/_/).first)
        if sampler_class == OpenTelemetry::Sampler::ParentBased
          subsample_class = get_sampler_class_from_name(
            normalize_sampler_name(sampler_class_name.split(/_/, 2).last))

          subsampler = get_sampler_instance_from_class_and_arg(subsample_class, default_traces_sampler_arg)
          sampler_class.new(subsampler)
        else
          get_sampler_instance_from_class_and_arg(sampler_class, default_traces_sampler_arg)
        end
      end

      private def self.normalize_sampler_name(name)
        case name.underscore
        when /^always_on/
          "alwayson"
        when /^always_off/
          "alwaysoff"
        when /^parent_based(.*)/
          "parentbased_#{$1}"
        else
          name
        end
      end

      def self.get_sampler_instance_from_class_and_arg(klass, arg = nil)
        if arg
          klass.new(arg)
        else
          klass.new
        end
      end

      def self.get_sampler_class_from_name(name)
        {% begin %}
        case
        {% for name in OpenTelemetry::Sampler.all_subclasses %}
        when {{ name.id.stringify.underscore.gsub(/_/, "").split("::").last }} =~ /#{name}/
          {{ name.id }}
        {% end %}
        else
          Sampler::AlwaysOn
        end
        {% end %}
      end

      def self.default_exporter_instance
        Exporter.new(variant: default_traces_exporter.to_s)
      end

      class Factory
        property service_name : String = ""
        property service_version : String = ""
        property schema_url : String = ""
        property exporter : Exporter? = nil
        property sampler : Sampler = Sampler::AlwaysOn.new
        property id_generator : IdGenerator

        # :nodoc:
        private def self._build(instance) : Configuration
          Configuration.new(
            service_name: Configuration.default_service_name ? Configuration.default_service_name.to_s : instance.service_name,
            service_version: Configuration.default_service_version ? Configuration.default_service_version.to_s : instance.service_version,
            schema_url: Configuration.default_schema_url ? Configuration.default_schema_url.to_s : instance.schema_url,
            exporter: Configuration.default_traces_exporter ? Configuration.default_exporter_instance : instance.exporter,
            sampler: Configuration.default_traces_sampler ? Configuration.default_sampler_instance : instance.sampler,
            id_generator: instance.id_generator
          )
        end

        def self.build(new_config : Configuration, &block : Factory ->) : Configuration
          build(
            service_name: new_config.service_name,
            service_version: new_config.service_version,
            schema_url: new_config.schema_url,
            exporter: new_config.exporter,
            sampler: new_config.sampler,
            id_generator: new_config.id_generator
          ) do |instance|
            block.call(instance)
          end
        end

        @[AlwaysInline]
        private def self.unknown_service
          "unknown_service:#{Path[Process.executable_path.to_s].basename}"
        end

        def self.build(configuration)
          instance = Factory.new(configuration)
          yield instance
          _build(instance)
        end

        def self.build(configuration)
          instance = Factory.new(configuration)
          _build(instance)
        end

        def self.build(
          service_name = unknown_service,
          service_version = "",
          schema_url = "",
          exporter = Exporter.new(:null),
          sampler = Sampler::AlwaysOn.new,
          id_generator = IdGenerator.new("unique")
        )
          instance = Factory.new(
            service_name: service_name,
            service_version: service_version,
            schema_url: schema_url,
            exporter: exporter,
            sampler: sampler,
            id_generator: id_generator)
          yield instance
          _build(instance)
        end

        def self.build(
          service_name = unknown_service,
          service_version = "",
          schema_url = "",
          exporter = Exporter.new(:null),
          sampler = Sampler::AlwaysOn.new,
          id_generator = IdGenerator.new("unique")
        )
          instance = Factory.new(
            service_name: service_name,
            service_version: service_version,
            schema_url: schema_url,
            exporter: exporter,
            sampler: sampler,
            id_generator: id_generator)
          _build(instance)
        end

        def initialize(
          @service_name,
          @service_version,
          @schema_url,
          @exporter,
          @sampler,
          @id_generator
        )
        end

        def initialize(configuration)
          @service_name = configuration.service_name
          @service_version = configuration.service_version
          @schema_url = configuration.schema_url
          @exporter = configuration.exporter
          @sampler = configuration.sampler
          @id_generator = configuration.id_generator
        end
      end
    end
  end
end

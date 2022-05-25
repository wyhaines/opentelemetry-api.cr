module OpenTelemetry
  # A `Configuration` is a `Struct` that is optimized to be a read-mostly data
  # structure. However, during creation of a `Configuration` instance, it can be
  # useful to have access to a read/write object for easy manipulation.
  #
  # The `OpenTelemetry::Configuration::Factory` provides this interface.
  class Provider
    struct Configuration
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
      def self.default_sampler
        sampler_class = get_sampler_class_from_name(default_traces_sampler.to_s.split(/_/).first)
        if sampler_class == OpenTelemetry::Sampler::ParentBased
          subsample_classr = get_sampler_class_from_name(default_traces_sampler.to_s.split(/_/, 2).last)

          subsampler = get_sampler_instance_from_class_and_arg(subsample_classr, default_traces_sampler_arg)
          sampler_class.new(subsampler)
        else
          get_sampler_instance_from_class_and_arg(sampler_class, default_traces_sampler_arg)
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
        puts "\nNAME: #{name}"
        {% begin %}
        case name.downcase
        {% for name in OpenTelemetry::InheritableSampler.all_subclasses %}
        when /{{ name.id.stringify.underscore }}/
          {{ name.id }}
        {% end %}
        else
          Sampler::AlwaysOn
        end
        {% end %}
      end

      class Factory
        property service_name : String = Configuration.default_service_name || ""
        property service_version : String = Configuration.default_service_version || ""
        property schema_url : String = Configuration.default_schema_url || ""
        property exporter : Exporter? = nil
        property sampler : Sampler = Configuration.default_traces_sampler ? Configuration.default_sampler : Sampler::AlwaysOn.new
        # property interval : Int32 = 5000
        property id_generator : IdGenerator

        # :nodoc:
        private def self._build(instance)
          Configuration.new(
            service_name: instance.service_name,
            service_version: instance.service_version,
            schema_url: instance.schema_url,
            exporter: instance.exporter,
            sampler: Configuration.default_traces_sampler ? Configuration.default_sampler : instance.sampler,
            # interval: instance.interval,
            id_generator: instance.id_generator
          )
        end

        def self.build(new_config : Configuration, &block : Factory ->)
          build(
            service_name: new_config.service_name,
            service_version: new_config.service_version,
            schema_url: new_config.schema_url,
            exporter: new_config.exporter,
            sampler: Configuration.default_traces_sampler ? Configuration.default_sampler : new_config.sampler,
            # interval: new_config.interval,
            id_generator: new_config.id_generator
          ) do |instance|
            block.call(instance)
          end
        end

        def self.build(
          service_name = "service_#{CSUUID.unique}",
          service_version = "",
          schema_url = "",
          exporter = Exporter.new(:abstract),
          sampler = Sampler::AlwaysOn.new,
          # interval = 5000,
          id_generator = IdGenerator.new("unique")
        )
          instance = Factory.allocate
          instance.initialize(
            service_name: service_name,
            service_version: service_version,
            schema_url: schema_url,
            exporter: exporter,
            sampler: Configuration.default_traces_sampler ? Configuration.default_sampler : sampler,
            # interval: interval,
            id_generator: id_generator)
          yield instance
          _build(instance)
        end

        def self.build(
          service_name = "service_#{CSUUID.unique}",
          service_version = "",
          schema_url = "",
          exporter = Exporter.new(:abstract),
          sampler = Sampler::AlwaysOn.new,
          # interval = 5000,
          id_generator = IdGenerator.new("unique")
        )
          instance = Factory.allocate
          instance.initialize(
            service_name: service_name,
            service_version: service_version,
            schema_url: schema_url,
            exporter: exporter,
            sampler: Configuration.default_traces_sampler ? Configuration.default_sampler : sampler,
            # interval: interval,
            id_generator: id_generator)
          _build(instance)
        end

        def initialize(
          @service_name,
          @service_version,
          @schema_url,
          @exporter,
          @sampler,
          # @interval,
          @id_generator
        )
          @sampler = Configuration.default_traces_sampler ? Configuration.default_sampler : @sampler
        end
      end
    end
  end
end

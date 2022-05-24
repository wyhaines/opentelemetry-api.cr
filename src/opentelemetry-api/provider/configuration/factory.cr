module OpenTelemetry
  # A `Configuration` is a `Struct` that is optimized to be a read-mostly data
  # structure. However, during creation of a `Configuration` instance, it can be
  # useful to have access to a read/write object for easy manipulation.
  #
  # The `OpenTelemetry::Configuration::Factory` provides this interface.
  class Provider
    struct Configuration
      DEFAULT_SERVICE_NAME       = ENV["OTEL_SERVICE_NAME"]?
      DEFAULT_SERVICE_VERSION    = ENV["OTEL_SERVICE_VERSION"]?
      DEFAULT_SCHEMA_URL         = ENV["OTEL_SCHEMA_URL"]?
      DEFAULT_TRACES_SAMPLER     = ENV["OTEL_TRACES_SAMPLER"]?
      DEFAULT_TRACES_SAMPLER_ARG = ENV["OTEL_TRACES_SAMPLER_ARG"]?
      DEFAULT_TRACES_EXPORTER    = ENV["OTEL_TRACES_EXPORTER"]?

      def self.default_sampler
        sampler_class = get_sampler_class_from_name(DEFAULT_TRACES_SAMPLER.to_s.split(/_/).first)
        if sampler_class == OpenTelemetry::Sampler::ParentBased
          subsample_classr = get_sampler_class_from_name(DEFAULT_TRACES_SAMPLER.to_s.split(/_/, 2).last)

          subsampler = get_sampler_instance_from_class_and_arg(subsample_classr, DEFAULT_TRACES_SAMPLER_ARG)
          sampler_class.new(subsampler)
        else
          get_sampler_instance_from_class_and_arg(sampler_class, DEFAULT_TRACES_SAMPLER_ARG)
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
        case name.downcase
        {% for name in OpenTelemetry::InheritableSampler.all_subclasses %}
        when {{ name.id.stringify.downcase }}
          {{ name.id }}
        {% end %}
        else
          Sampler::AlwaysOn
        end
        {% end %}
      end

      class Factory
        property service_name : String = DEFAULT_SERVICE_NAME || ""
        property service_version : String = DEFAULT_SERVICE_VERSION || ""
        property schema_url : String = DEFAULT_SCHEMA_URL || ""
        property exporter : Exporter? = nil
        property sampler : Sampler = DEFAULT_TRACES_SAMPLER ? Configuration.default_sampler : Sampler::AlwaysOn.new
        # property interval : Int32 = 5000
        property id_generator : IdGenerator

        # :nodoc:
        private def self._build(instance)
          Configuration.new(
            service_name: instance.service_name,
            service_version: instance.service_version,
            schema_url: instance.schema_url,
            exporter: instance.exporter,
            sampler: DEFAULT_TRACES_SAMPLER ? Configuration.default_sampler : instance.sampler,
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
            sampler: DEFAULT_TRACES_SAMPLER ? Configuration.default_sampler : new_config.sampler,
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
            sampler: DEFAULT_TRACES_SAMPLER ? Configuration.default_sampler : sampler,
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
            sampler: DEFAULT_TRACES_SAMPLER ? Configuration.default_sampler : sampler,
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
          @sampler = DEFAULT_TRACES_SAMPLER ? Configuration.default_sampler : @sampler
        end
      end
    end
  end
end

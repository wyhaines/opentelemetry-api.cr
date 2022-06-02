require "./configuration/factory"

module OpenTelemetry
  class Provider
    # This class encapsulates the configuration for a TraceProvider.
    class Configuration
      property service_name : String = ""
      property service_version : String = ""
      property schema_url : String = ""
      property exporter : Exporter? = nil
      property sampler : Sampler = Sampler::AlwaysOn.new
      property id_generator : IdGenerator = IdGenerator.new("unique")

      def initialize(
        @service_name : String = "",
        @service_version : String = "",
        @schema_url : String = "",
        @exporter : Exporter? = nil,
        @sampler : Sampler = Sampler::AlwaysOn.new,
        id_generator : IdGenerator = IdGenerator.new("unique")
      )
      end

      def initialize(
        @service_name : String = "",
        @service_version : String = "",
        @schema_url : String = "",
        @exporter : Exporter? = nil,
        @sampler : Sampler = Sampler::AlwaysOn.new,
        id_generator : String = "unique"
      )
        @id_generator = IdGenerator.new(id_generator)
      end

      # Ensure that any resources, like fibers, are shut down when a TracerProvider object is collected.
      def finalize
        @exporter.try(&.exporter).try(&.do_reap)
      end
    end
  end
end

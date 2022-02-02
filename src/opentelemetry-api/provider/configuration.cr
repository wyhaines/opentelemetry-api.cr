require "./configuration/factory"

module OpenTelemetry
  class Provider
    # This class encapsulates the configuration for a TraceProvider.
    record Configuration,
      service_name : String = "",
      service_version : String = "",
      schema_url : String = "",
      exporter : Exporter? = nil,
      id_generator : IdGenerator = IdGenerator.new("unique") do
      def initialize(
        @service_name : String = "",
        @service_version : String = "",
        schema_url : String = "",
        @exporter : Exporter? = nil,
        id_generator : String = "unique"
      )
        @service_name = service_name
        @service_version = service_version
        @schema_url = schema_url
        @exporter = exporter
        @id_generator = IdGenerator.new(id_generator)
      end
    end
  end
end

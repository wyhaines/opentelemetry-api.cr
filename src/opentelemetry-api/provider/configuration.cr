require "./configuration/factory"

module OpenTelemetry
  class Provider
    # This class encapsulates the configuration for a TraceProvider.
    record Configuration,
      service_name : String = "",
      service_version : String = "",
      schema_url : String = "",
      exporter : Exporter? = nil,
      interval : Int32 = 5000,
      id_generator : IdGenerator = IdGenerator.new("unique") do
      def initialize(
        @service_name : String = "",
        @service_version : String = "",
        @schema_url : String = "",
        @exporter : Exporter? = nil,
        @interval : Int32 = 5000,
        id_generator : String = "unique"
      )
        @id_generator = IdGenerator.new(id_generator)
      end
    end
  end
end

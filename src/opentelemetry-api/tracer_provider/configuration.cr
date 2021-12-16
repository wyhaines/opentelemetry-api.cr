require "./configuration/factory"

module OpenTelemetry
  class TracerProvider
    # This class encapsulates the configuration for a TracerProvider.
    record Configuration,
      service_name : String,
      service_version : String = "",
      exporter : Exporter = NullExporter.new,
      id_generator : String = "unique"
  end
end

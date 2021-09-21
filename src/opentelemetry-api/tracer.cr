module OpenTelemetry
  class Tracer
    property service_name : String = ""
    property service_version : String = ""
    property exporter : Exporter = NullExporter.new
    getter provider : TracerProvider = TracerProvider.new

    def initialize(
      provider = nil,
      service_name = nil,
      service_version = nil,
      exporter = nil
    )
      self.provider = provider if provider
      self.service_name = service_name if service_name
      self.service_version = service_version if service_version
      self.exporter = exporter if exporter
    end

    def provider=(val)
      @provider = val
      self.service_name = @provider.service_name
      self.service_version = @provider.service_version
      self.exporter = @provider.exporter
    end
  end
end

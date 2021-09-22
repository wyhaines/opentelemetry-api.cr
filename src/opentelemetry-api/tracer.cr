module OpenTelemetry
  class Tracer
    property service_name : String = ""
    property service_version : String = ""
    property exporter : Exporter = AbstractExporter.new
    getter provider : TracerProvider = TracerProvider.new

    def initialize(
      service_name = nil,
      service_version = nil,
      exporter = nil,
      provider = nil
    )
      self.provider = provider if provider
      self.service_name = service_name if service_name
      self.service_version = service_version if service_version
      self.exporter = exporter if exporter
    end

    def provider=(val)
      self.service_name = @provider.service_name
      self.service_version = @provider.service_version
      self.exporter = @provider.exporter
      @provider = val
    end

    def merge_configuration_from_provider=(val)
      self.service_name = val.service_name if self.service_name.nil? || self.service_name.empty?
      self.service_version = val.service_version if self.service_version.nil? || self.service_version.empty?
      self.exporter = val.exporter if self.exporter.nil? || self.exporter.is_a?(AbstractExporter)
      @provider = val
    end
  end
end

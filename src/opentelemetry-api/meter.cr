require "./meter/exceptions"
require "./instrument"

module OpenTelemetry
  class Meter
    property meter_name : String = ""
    property service_name : String = ""
    property service_version : String = ""
    property schema_url : String = ""
    property exporter : Exporter? = nil
    getter provider : MeterProvider = MeterProvider.new
    @instrumentation_library = {} of String => Instruments
    @exported : Bool = false
    @lock : Mutex = Mutex.new

    def initialize(
      service_name = nil,
      service_version = nil,
      schema_url = nil,
      exporter = nil,
      provider = nil
    )
      self.provider = provider if provider
      self.service_name = service_name if service_name
      self.service_version = service_version if service_version
      self.schema_url = schema_url if schema_url
      self.exporter = exporter if exporter
      self.trace_id = @provider.id_generator.trace_id
    end

    def provider=(val)
      self.service_name = @provider.service_name
      self.service_version = @provider.service_version
      self.schema_url = @provider.schema_url
      self.exporter = @provider.exporter
      @provider = val
    end

    def merge_configuration_from_provider=(val)
      self.service_name = val.service_name if self.service_name.nil? || self.service_name.empty?
      self.service_version = val.service_version if self.service_version.nil? || self.service_version.empty?
      self.schema_url = val.schema_url if self.schema_url.nil? || self.schema_url.empty?
      self.exporter = val.exporter if self.exporter.nil? || self.exporter.try(&.exporter).is_a?(Exporter::Abstract)
      @provider = val
    end

    # This method returns a ProtoBuf object containing all of the Trace information.
    def to_protobuf
      Proto::Trace::V1::ResourceSpans.new(
        instrumentation_library_spans: [
          Proto::Trace::V1::InstrumentationLibrarySpans.new(
            instrumentation_library: Proto::Common::V1::InstrumentationLibrary.new(
              name: "OpenTelemetry Crystal",
              version: VERSION,
            ),
            spans: iterate_span_nodes(root_span, [] of Span).map(&.to_protobuf)
          ),
        ],
      )
    end

    def to_json
      String.build do |json|
        json << "{\n"
        json << "  \"type\":\"trace\",\n"
        json << "  \"traceId\":\"#{trace_id.hexstring}\",\n"
        json << "  \"spans\":[\n"
        json << String.build do |span_list|
          iterate_span_nodes(root_span) do |span|
            span_list << "    "
            span_list << span.to_json if span
            span_list << ",\n"
          end
        end.chomp(",\n")
        json << "\n  ]\n"
        json << "}"
      end
    end
  end
end

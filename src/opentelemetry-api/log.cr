require "../proto/logs.pb"
require "../proto/logs_service.pb"
require "./trace/exceptions"

module OpenTelemetry
  class Log
    property exporter : Exporter? = nil

    property timestamp : Time::Span = Time.monotonic
    property observed_timestamp : Time::Span = Time.monotonic
    property trace_id : Slice(UInt8)? = nil
    property span_id : Slice(UInt8)? = nil
    property trace_flags : BitArray = BitArray.new(8)
    property severity_text : String = "INFO"
    property severity_number : UInt8 = 1

    @exported : Bool = false
    @lock : Mutex = Mutex.new

    def self.severity_name_from_number(number)
      number_to_i = number.to_i
      n = case number_to_i
      when 1..4
        name = "TRACE"
        number_to_i
      when 5..8
        name = "DEBUG"
        number_to_i - 4
      when 9..12
        name = "INFO"
        number_to_i - 8
      when 13..16
        name = "WARN"
        number_to_i - 12
      when 17..20
        name = "ERROR"
        number_to_i - 16
      when 21..24
        name = "FATAL"
        number_to_i - 20
      else
        raise "Invalid severity number; severity must be in the range of 1..24"
      end

      "#{name}#{n == 1 ? "" : n}"
    end

    def self.severity_number_from_name(name)
      parts = name.scan(/[a-zA-Z]+|\d+/).map(&.string)
      raise "Severity name not formatted correctly; LABEL|LABELn where LABEL is one of TRACE, DEBUG, INFO, WARN, ERROR, or FATAL and n is an optional number" if !(1..2).includes?(parts.size)

      name = parts[0].upcase
      n = parts[1]? ? (parts[1].to_i - 1) : 0

      raise "Invalid severity sublevel; must be blank (i.e. TRACE) or 2..4 (i.e. TRACE4)" if !(0..3).includes?(n)
      level = case name
      when "TRACE"
        n + 1
      when "DEBUG"
        n + 5
      when "INFO"
        n + 9
      when "WARN"
        n + 13
      when "ERROR"
        n + 17
      when "FATAL"
        n + 21
      else
        raise "Invalid severity name; severity must be one of TRACE, DEBUG, INFO, WARN, ERROR, or FATAL"
      end

      level
    end

    def initialize(

    )
    end

  #   def provider=(val)
  #     self.service_name = @provider.service_name
  #     self.service_version = @provider.service_version
  #     self.schema_url = @provider.schema_url
  #     self.exporter = @provider.exporter
  #     @provider = val
  #   end

  #   def merge_configuration_from_provider=(val)
  #     self.service_name = val.service_name if self.service_name.nil? || self.service_name.empty?
  #     self.service_version = val.service_version if self.service_version.nil? || self.service_version.empty?
  #     self.schema_url = val.schema_url if self.schema_url.nil? || self.schema_url.empty?
  #     self.exporter = val.exporter if self.exporter.nil? || self.exporter.try(&.exporter).is_a?(Exporter::Abstract)
  #     @provider = val
  #   end

  #   def to_protobuf
  #     Proto::Trace::V1::ResourceSpans.new(
  #       instrumentation_library_spans: [
  #         Proto::Trace::V1::InstrumentationLibrarySpans.new(
  #           instrumentation_library: Proto::Common::V1::InstrumentationLibrary.new(
  #             name: "OpenTelemetry Crystal",
  #             version: VERSION,
  #           ),
  #           spans: iterate_span_nodes(root_span, [] of Span).map(&.to_protobuf)
  #         ),
  #       ],
  #     )
  #   end

  #   def to_json
  #     String.build do |json|
  #       json << "{\n"
  #       json << "  \"type\":\"trace\",\n"
  #       json << "  \"traceId\":\"#{trace_id.hexstring}\",\n"
  #       json << "  \"spans\":[\n"
  #       json << String.build do |span_list|
  #         iterate_span_nodes(root_span) do |span|
  #           span_list << "    "
  #           span_list << span.to_json if span
  #           span_list << ",\n"
  #         end
  #       end.chomp(",\n")
  #       json << "\n  ]\n"
  #       json << "}"
  #     end
  #   end
  end
end

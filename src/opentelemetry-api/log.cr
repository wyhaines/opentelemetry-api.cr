require "../proto/logs.pb"
require "../proto/logs_service.pb"
require "./trace/exceptions"

module OpenTelemetry
  class Log
    enum Level
      Trace = 1
      Trace2 = 2
      Trace3 = 3
      Trace4 = 4
      Debug = 5
      Debug2 = 6
      Debug3 = 7
      Debug4 = 8
      Info = 9
      Info2 = 10
      Info3 = 11
      Info4 = 12
      Warn = 13
      Warn2 = 14
      Warn3 = 15
      Warn4 = 16
      Error = 17
      Error2 = 18
      Error3 = 19
      Error4 = 20
      Fatal = 21
      Fatal2 = 22
      Fatal3 = 23
      Fatal4 = 24
    end

    property exporter : Exporter? = nil

    property timestamp : Time::Span = Time.monotonic
    property observed_timestamp : Time::Span = Time.monotonic
    property trace_id : Slice(UInt8)? = nil
    property span_id : Slice(UInt8)? = nil
    property trace_flags : BitArray = BitArray.new(8)
    property severity : Level = Level::Info
    property message : String = ""

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
      parts = name.upcase.scan(/[a-zA-Z]+|\d+/).map(&.to_a.first.to_s)
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
      @severity : Level = Level::Info,
      @message : String = "",
      @timestamp : Time::Span = Time.monotonic,
      @observed_timestamp : Time::Span? = nil,
      @trace_id : Slice(Uint8)? = nil,
      @span_id : Slice(Uint8)? = nil,
      @trace_flags : BitArray = BitArray.new(8),
      @exporter : Exporter? = nil
    )
      @observed_timestamp = @timestamp unless @observed_timestamp
    end

    def initialize(
      severity : String = "Info",
      @message : String = "",
      @timestamp : Time::Span = Time.monotonic,
      @observed_timestamp : Time::Span? = nil,
      @trace_id : Slice(Uint8)? = nil,
      @span_id : Slice(Uint8)? = nil,
      @trace_flags : BitArray = BitArray.new(8),
      @exporter : Exporter? = nil
    )
      @severity = self.class.severity_number_from_name(severity)
      @observed_timestamp = @timestamp unless @observed_timestamp
    end

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

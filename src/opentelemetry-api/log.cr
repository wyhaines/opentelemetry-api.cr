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

    property timestamp : Time = Time.utc
    property observed_timestamp : Time = Time.utc
    property trace_id : Slice(UInt8)? = nil
    property span_id : Slice(UInt8)? = nil
    property trace_flags : BitArray = BitArray.new(8)
    property severity : Level = Level::Info
    property message : String = ""

    @exported : Bool = false
    @lock : Mutex = Mutex.new

    def self.severity_from_number(number)
      number_to_i = number.to_i
      case number_to_i
      when 1
        Level::Trace
      when 2
        Level::Trace2
      when 3
        Level::Trace3
      when 4
        Level::Trace4
      when 5
        Level::Debug
      when 6
        Level::Debug2
      when 7
        Level::Debug3
      when 8
        Level::Debug4
      when 9
        Level::Info
      when 10
        Level::Info2
      when 11
        Level::Info3
      when 12
        Level::Info4
      when 13
        Level::Warn
      when 14
        Level::Warn2
      when 15
        Level::Warn3
      when 16
        Level::Warn4
      when 17
        Level::Error
      when 18
        Level::Error2
      when 19
        Level::Error3
      when 20
        Level::Error4
      when 21
        Level::Fatal
      when 22
        Level::Fatal2
      when 23
        Level::Fatal3
      when 24
        Level::Fatal4
      else
        raise "Invalid severity number; severity must be in the range of 1..24"
      end
    end

    def self.severity_from_name(name)
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

      Level.new(level)
    end

    private def initialize_impl(
      @severity : Level = Level::Info,
      @message : String = "",
      @timestamp : Time = Time.utc,
      observed_timestamp : Time? = nil,
      @trace_id : Slice(UInt8)? = nil,
      @span_id : Slice(UInt8)? = nil,
      @trace_flags : BitArray = BitArray.new(8),
      @exporter : Exporter? = nil
    )
      @observed_timestamp = timestamp unless observed_timestamp
    end

    def initialize(
      severity : Level = Level::Info,
      message : String = "",
      timestamp : Time = Time.utc,
      observed_timestamp : Time? = nil,
      trace_id : Slice(UInt8)? = nil,
      span_id : Slice(UInt8)? = nil,
      trace_flags : BitArray = BitArray.new(8),
      exporter : Exporter? = nil
    )

      initialize_impl(
        severity,
        message,
        timestamp,
        observed_timestamp,
        trace_id,
        span_id,
        trace_flags,
        exporter)
    end

    def initialize(
      severity : String = "INFO",
      message : String = "",
      timestamp : Time = Time.utc,
      observed_timestamp : Time? = nil,
      trace_id : Slice(UInt8)? = nil,
      span_id : Slice(UInt8)? = nil,
      trace_flags : BitArray = BitArray.new(8),
      exporter : Exporter? = nil
    )

      initialize_impl(
        self.class.severity_from_name(severity),
        message,
        timestamp,
        observed_timestamp,
        trace_id,
        span_id,
        trace_flags,
        exporter)
    end

    def initialize(
      severity : Int = 9,
      message : String = "",
      timestamp : Time = Time.utc,
      observed_timestamp : Time? = nil,
      trace_id : Slice(UInt8)? = nil,
      span_id : Slice(UInt8)? = nil,
      trace_flags : BitArray = BitArray.new(8),
      exporter : Exporter? = nil
    )

      initialize_impl(
        self.class.severity_from_number(severity),
        message,
        timestamp,
        observed_timestamp,
        trace_id,
        span_id,
        trace_flags,
        exporter)
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

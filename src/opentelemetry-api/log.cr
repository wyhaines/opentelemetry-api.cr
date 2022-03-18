require "../proto/logs.pb"
require "../proto/logs_service.pb"
# require "./trace/exceptions"
require "./sendable"

module OpenTelemetry
  class LogRecord
    include Sendable

    NAME_OFFSETS = {
      "UNSPECIFIED" => ->(_n : Int32) { 0 },
      "TRACE"       => ->(n : Int32) { n + 1 },
      "DEBUG"       => ->(n : Int32) { n + 5 },
      "INFO"        => ->(n : Int32) { n + 9 },
      "WARN"        => ->(n : Int32) { n + 13 },
      "ERROR"       => ->(n : Int32) { n + 17 },
      "FATAL"       => ->(n : Int32) { n + 21 },
    }

    enum Level
      Unspecified =  0
      Trace       =  1
      Trace2      =  2
      Trace3      =  3
      Trace4      =  4
      Debug       =  5
      Debug2      =  6
      Debug3      =  7
      Debug4      =  8
      Info        =  9
      Info2       = 10
      Info3       = 11
      Info4       = 12
      Warn        = 13
      Warn2       = 14
      Warn3       = 15
      Warn4       = 16
      Error       = 17
      Error2      = 18
      Error3      = 19
      Error4      = 20
      Fatal       = 21
      Fatal2      = 22
      Fatal3      = 23
      Fatal4      = 24
    end

    property exporter : Exporter? = nil
    property schema_url : String = ""

    property time : Time? = nil
    property observed_time : Time? = nil
    property trace_id : Slice(UInt8)? = nil
    property span_id : Slice(UInt8)? = nil
    property flags : TraceFlags = TraceFlags.new(0x00)
    property severity : Level = Level::Unspecified
    property severity_text : String? = nil
    property name : String? = nil
    property attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
    property dropped_attribute_count : UInt32 = 0

    @body : AnyValue? = nil
    @exported : Bool = false
    @lock : Mutex = Mutex.new

    def self.severity_from_number(number)
      if number.to_i > 0 && number.to_i < 25
        Level.new(number.to_i)
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
      level = NAME_OFFSETS[name]? ||
              raise "Invalid severity name; severity must be one of TRACE, DEBUG, INFO, WARN, ERROR, or FATAL"

      Level.new(level.call(n))
    end

    private def initialize_impl(
      @severity : Level = Level::Unspecified,
      severity_text : String? = nil,
      body : ValueTypes? = nil,
      @time : Time? = nil,
      observed_time : Time? = nil,
      @trace_id : Slice(UInt8)? = nil,
      @span_id : Slice(UInt8)? = nil,
      @flags : TraceFlags = TraceFlags.new(0x00),
      @exporter : Exporter? = nil
    )
      @severity_text = severity_text || @severity.to_s
      @observed_time = observed_time || @time
      self.body = body
    end

    def initialize(
      severity : Level = Level::Unspecified,
      severity_text : String? = nil,
      body : ValueTypes? = nil,
      time : Time? = nil,
      observed_time : Time? = nil,
      trace_id : Slice(UInt8)? = nil,
      span_id : Slice(UInt8)? = nil,
      flags : TraceFlags = TraceFlags.new(0x00),
      exporter : Exporter? = nil
    )
      initialize_impl(
        severity: severity,
        severity_text: severity_text,
        body: body,
        time: time,
        observed_time: observed_time,
        trace_id: trace_id,
        span_id: span_id,
        flags: flags,
        exporter: exporter)
    end

    def initialize(
      severity : String = "UNSPECIFIED",
      severity_text : String? = nil,
      body : ValueTypes? = nil,
      time : Time? = nil,
      observed_time : Time? = nil,
      trace_id : Slice(UInt8)? = nil,
      span_id : Slice(UInt8)? = nil,
      flags : TraceFlags = TraceFlags.new(0x00),
      exporter : Exporter? = nil
    )
      initialize_impl(
        severity: self.class.severity_from_name(severity),
        severity_text: severity_text,
        body: body,
        time: time,
        observed_time: observed_time,
        trace_id: trace_id,
        span_id: span_id,
        flags: flags,
        exporter: exporter)
    end

    def initialize(
      severity : Int = 0,
      severity_text : String? = nil,
      body : ValueTypes? = nil,
      time : Time? = nil,
      observed_time : Time? = nil,
      trace_id : Slice(UInt8)? = nil,
      span_id : Slice(UInt8)? = nil,
      flags : TraceFlags = TraceFlags.new(0x00),
      exporter : Exporter? = nil
    )
      initialize_impl(
        severity: self.class.severity_from_number(severity),
        severity_text: severity_text,
        body: body,
        time: time,
        observed_time: observed_time,
        trace_id: trace_id,
        span_id: span_id,
        flags: flags,
        exporter: exporter)
    end

    def []=(key, value)
      attributes[key] = AnyAttribute.new(key: key, value: value)
    end

    def set_attribute(key, value)
      self[key] = value
    end

    def [](key)
      attributes[key].value
    end

    def get_attribute(key)
      attributes[key]
    end

    def body=(val)
      if val.nil?
        @body = nil
      else
        @body = AnyValue.new(val)
      end
    end

    def body
      if b = @body
        b.value
      else
        nil
      end
    end

    def merge_configuration_from_provider=(val)
      # self.service_name = val.service_name if self.service_name.nil? || self.service_name.empty?
      # self.service_version = val.service_version if self.service_version.nil? || self.service_version.empty?
      self.schema_url = val.schema_url if self.schema_url.nil? || self.schema_url.empty?
      self.exporter = val.exporter if self.exporter.nil? || self.exporter.try(&.exporter).is_a?(Exporter::Abstract)
      @provider = val
    end

    def time_unix_nano
      if t = time
        (t - Time::UNIX_EPOCH).total_nanoseconds.to_u64
      else
        0
      end
    end

    def observed_time_unix_nano
      if ot = observed_time
        (ot - Time::UNIX_EPOCH).total_nanoseconds.to_u64
      else
        0
      end
    end

    # The ProtoBuf differs a LOT from the current Spec. Methinks this has changed a bunch since I last updated it.
    def to_protobuf
      Proto::Trace::V1::Log.new(
        time_unix_nano: time_unix_nano,
        observed_time_unix_nano: observed_time_unix_nano,
        severity_number: @severity.value,
        severity_text: @severity.to_s,
        body: body.value,
        trace_id: @trace_id,
        span_id: @span_id,
              # flags: @flags
)
    end

    def to_json
      String.build do |json|
        json << "{\n"
        json << "    \"time_unix_nano\":\"#{time_unix_nano}\"\n" if time_unix_nano
        json << "    \"time_unix_nano\":\"#{time_unix_nano}\"\n" if observed_time_unix_nano
        json << "    \"severity_text\":\"#{severity_text}\"\n" if severity_text
        json << "}"
      end
    end

    # Individual logs can export themselves. This is less efficient than using a LogProvider,
    # and allowing the LogProvider to export larger chucks of logs, but this capability may
    # be useful if log volume is not large.
    def export
    end
  end
end

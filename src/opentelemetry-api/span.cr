require "./span_context"
require "./span/*"
require "./status"
require "./event"
require "json"
require "./sendable"

module OpenTelemetry
  # A `Span` represents a single measured timespan, and all data associated
  # with that measurement. A `Span` may nest other `Span` instances.
  class Span
    include Sendable

    property name : String = ""
    property start : Time::Span = Time.monotonic
    property wall_start : Time = Time.utc
    property finish : Time::Span? = nil
    property wall_finish : Time? = nil
    property events : Array(Event) = [] of Event
    property attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
    property parent : Span? = nil
    property children : Array(Span) = [] of Span
    property context : SpanContext = SpanContext.new
    property kind : Kind = Kind::Internal
    property status : Status = Status.new
    property is_recording : Bool = true

    MATCH = /(?<span_id>[A-Fa-f0-9]{16})/

    def self.validate_id(id : Slice(UInt8))
      validate_id(id.hexstring)
    end

    def self.validate_id(id : Slice)
      !!MATCH.match id
    end

    def self.build(name = "")
      span = new(name)
      yield span

      span
    end

    def initialize(@name = "")
    end

    def recording?
      @is_recording
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

    def add_event(name)
      events << Event.new(name: name)
    end

    def add_event(name = "")
      events << Event.new(name: name) do |event|
        yield event
      end
    end

    def add_event(name, attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute)
      events << Event.new(name: name, attributes: attributes)
    end

    def id
      context.span_id
    end

    def span_id
      id
    end

    def start_time_unix_nano
      (wall_start - Time::UNIX_EPOCH).total_nanoseconds.to_u64
    end

    def end_time_unix_nano
      if _wall_finish = wall_finish
        (_wall_finish - Time::UNIX_EPOCH).total_nanoseconds.to_u64
      else
        0_u64
      end
    end

    def client!
      self.kind = Kind::Client
    end

    def server!
      self.kind = Kind::Server
    end

    def producer!
      self.kind = Kind::Producer
    end

    def consumer!
      self.kind = Kind::Consumer
    end

    def internal!
      self.kind = Kind::Internal
    end

    def pb_span_kind
      case @kind
      when Kind::Client
        Proto::Trace::V1::Span::SpanKind::SPANKINDCLIENT
      when Kind::Server
        Proto::Trace::V1::Span::SpanKind::SPANKINDSERVER
      when Kind::Producer
        Proto::Trace::V1::Span::SpanKind::SPANKINDPRODUCER
      when Kind::Consumer
        Proto::Trace::V1::Span::SpanKind::SPANKINDCONSUMER
      when Kind::Internal
        Proto::Trace::V1::Span::SpanKind::SPANKINDINTERNAL
      else
        Proto::Trace::V1::Span::SpanKind::SPANKINDUNSPECIFIED
      end
    end

    def pb_span_status
      case @status
      when Status::Unset
        Proto::Trace::V1::Status::StatusCode::STATUSCODEUNSET
      when Status::Ok
        Proto::Trace::V1::Status::StatusCode::STATUSCODEOK
      else
        Proto::Trace::V1::Status::StatusCode::STATUSCODEERROR
      end
    end

    @[AlwaysInline]
    def can_export?
      context.trace_flags.sampled? && recording?
    end

    # Return the Protobuf object for the Span.
    def to_protobuf
      return unless can_export?

      span = Proto::Trace::V1::Span.new(
        name: name,
        trace_id: context.trace_id,
        span_id: context.span_id,
        parent_span_id: parent.try(&.context.span_id),
        start_time_unix_nano: start_time_unix_nano,
        end_time_unix_nano: end_time_unix_nano,
        kind: pb_span_kind,
        status: status.to_protobuf
      )

      span.attributes = attributes.map do |key, value|
        Proto::Common::V1::KeyValue.new(
          key: key,
          value: Attribute.to_anyvalue(value))
      end

      span.events = events.map(&.to_protobuf)

      span
    end

    def to_json
      return "" unless can_export?
      JSON.build(indent: "  ") do |json|
        self.to_json(json)
      end
    end

    def to_json(json : JSON::Builder)
      if can_export?
        json.object do
          json.field "type", "span"
          json.field "traceId", context.trace_id.hexstring
          json.field "spanId", context.span_id.hexstring
          json.field "parentSpanId", parent.try(&.context.span_id.hexstring)
          json.field "kind", kind.value
          json.field "name", name
          json.field "status", status.to_json
          json.field "startTime", start_time_unix_nano
          json.field "endTime", end_time_unix_nano
          json.field "attributes" do
            json.object do
              attributes.each do |_, value|
                json.field value.key, value.value
              end
            end
          end
          json.field "events" do
            json.array do
              events.each do |event|
                event.to_json(json)
              end
            end
          end
          json
        end
      else
        json.object do
        end
      end
    end
  end
end

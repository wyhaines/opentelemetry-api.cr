require "./span_context"
require "./span/kind"
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

    def initialize(@name = "")
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

    # Return the Protobuf object for the Span.
    def to_protobuf
      span = Proto::Trace::V1::Span.new(
        name: name,
        trace_id: context.trace_id,
        span_id: context.span_id,
        parent_span_id: parent.try(&.context.span_id),
        start_time_unix_nano: start_time_unix_nano,
        end_time_unix_nano: end_time_unix_nano,
        kind: pb_span_kind,
      )

      span.attributes = attributes.map do |key, value|
        Proto::Common::V1::KeyValue.new(
          key: key,
          value: Attribute.to_anyvalue(value))
      end

      span
    end

    def to_json
      String.build do |json|
        json << "{\n"
        json << "      \"type\":\"span\",\n"
        json << "      \"traceId\":\"#{context.trace_id.hexstring}\",\n"
        json << "      \"spanId\":\"#{context.span_id.hexstring}\",\n"
        json << "      \"parentSpanId\":\"#{parent.try(&.context.span_id.hexstring)}\",\n"
        json << "      \"kind\":\"#{kind.to_s.upcase}\",\n"
        json << "      \"name\":\"#{name}\",\n"
        json << "      \"startTime\":#{start_time_unix_nano},\n"
        json << "      \"endTime\":#{end_time_unix_nano},\n"
        json << "      \"attributes\":{\n"
        json << String.build do |attribute_list|
          attributes.each do |_, value|
            attribute_list << "        #{value.to_json},\n"
          end
        end.chomp(",\n")
        json << "      },\n"
        json << "      \"events\":[\n"
        json << String.build do |event_list|
          events.each do |event|
            event_list << "    #{event.to_json},\n"
          end
        end.chomp(",\n")
        json << "\n      ]\n"

        json << "}"
      end
    end
  end
end

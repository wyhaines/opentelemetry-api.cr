require "./span_context"
require "./status"
require "./event"
require "./sendable"
require "./abstract_span"
require "./span/kind"
require "json"

module OpenTelemetry
  module API
    # A `Span` represents a single measured timespan, and all data associated
    # with that measurement. A `Span` may nest other `Span` instances.
    class Span < AbstractSpan
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

      def initialize(@name = "")
      end

      def recording?
      end

      def []=(key, value)
      end

      def set_attribute(key, value)
      end

      def [](key)
      end

      def get_attribute(key)
      end

      def add_event(name)
      end

      def add_event(name = "", & : Event ->)
        yield Event.new(name)
      end

      def add_event(name, attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute)
      end

      def id
      end

      def span_id
      end

      def client!
      end

      def server!
      end

      def producer!
      end

      def consumer!
      end

      def internal!
      end

      def can_export?
      end

      # Return the Protobuf object for the Span.
      def to_protobuf
      end

      def to_json
      end

      def to_json(json : JSON::Builder)
      end
    end
  end
end

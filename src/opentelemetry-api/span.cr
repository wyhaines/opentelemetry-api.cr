require "./span_context"
require "./event"

module OpenTelemetry
  # A `Span` represents a single measured timespan, and all data associated
  # with that measurement. A `Span` may nest other `Span` instances.
  class Span
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

    def add_event(name = "", &blk : Event ->)
      events << Event.new(name: name, &blk)
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
  end
end

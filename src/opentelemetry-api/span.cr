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
    property attributes : Hash(String, Attribute) = {} of String => Attribute
    property parent : Span? = nil

    def initialize(@name = "")
    end

    def []=(key, value)
      unless attributes.has_key?(key)
        attributes[key] = Attribute.new(key: key, value: ValueArray.new)
      end
      attributes[key].value << value
    end

    def set_attribute(key, value)
      self[key] = value
    end

    def [](key)
      val = attributes[key].value
      if val.size > 1
        val
      else
        val.first
      end
    end

    def get_attribute(key)
      self[key]
    end
  end
end

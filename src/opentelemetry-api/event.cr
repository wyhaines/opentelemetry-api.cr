require "./attribute"

module OpenTelemetry
  class Event
    property identifier : CSUUID = CSUUID.unique
    property name : String = ""
    property timestamp : Time::Span = Time.monotonic
    property wall_timestamp : Time = Time.utc
    getter attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
    property parent_span : Span? = nil

    def initialize(@name)
    end

    def initialize(@name = "", &blk : Event ->)
      yield self
    end

    def initialize(@name, @attributes : Hash(String, AnyAttribute))
    end

    def initialize(@name, attributes : Hash(String, _))
      @attributes = {} of String => AnyAttribute
      attributes.each do |k, v|
        @attributes[k] = AnyAttribute.new(k, v)
      end
    end

    def attributes=(attr : Hash(String, _))
      @attributes = {} of String => AnyAttribute
      attr.each do |k, v|
        @attributes[k] = AnyAttribute.new(k, v)
      end
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
  end
end

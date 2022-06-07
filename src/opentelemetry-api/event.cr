require "./attribute"

module OpenTelemetry
  class Event
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

    def time_unix_nano
      (wall_timestamp - Time::UNIX_EPOCH).total_nanoseconds.to_u64
    end

    def to_protobuf
      Proto::Trace::V1::Span::Event.new(
        name: name,
        time_unix_nano: time_unix_nano,
        attributes: attributes.map do |key, value|
          Proto::Common::V1::KeyValue.new(
            key: key,
            value: Attribute.to_anyvalue(value))
        end)
    end

    def to_json
      JSON.build do |json|
        self.to_json(json)
      end
    end

    def to_json(json : JSON::Builder)
      json.object do
        json.field "type", "event"
        json.field "timestamp", time_unix_nano
        json.field "name", name
        if !attributes.empty?
          json.field "attributes" do
            json.object do
              attributes.each do |_, value|
                json.field value.key, value.value
              end
            end
          end
        end
      end
    end
  end
end

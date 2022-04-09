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

    def to_json
      String.build do |json|
        json << "    {\n"
        json << "          \"type\": \"event\",\n"
        json << "          \"name\": \"#{name}\",\n"
        if !attributes.empty?
          json << "          \"attributes\":{\n"
          json << String.build do |attr_json|
            attributes.each do |_, value|
              attr_json << "            #{value.to_json},\n"
            end
          end.chomp(",\n")
          json << "\n          },\n"
        end
        json << "          \"timestamp\": #{time_unix_nano}\n"
        json << "        }"
      end
    end
  end
end

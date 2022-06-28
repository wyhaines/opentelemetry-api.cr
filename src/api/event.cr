module OpenTelemetry
  module API
    class Event < OpenTelemetry::API::AbstractEvent
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
      end

      def attributes=(attr : Hash(String, _))
      end

      def []=(key, value)
      end

      def set_attribute(key, value)
      end

      def [](key)
      end

      def get_attribute(key)
      end

      def to_protobuf
      end

      def to_json
      end

      def to_json(json : JSON::Builder)
      end
    end
  end
end

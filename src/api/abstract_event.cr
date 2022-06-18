module OpenTelemetry
  module API
    abstract class AbstractEvent
      abstract def name : String
      abstract def name=(val)

      abstract def timestamp : Time::Span
      abstract def timestamp=(val) # default to Time.monotonic

      abstract def wall_timestamp : Time
      abstract def wall_timestamp=(val) # default to Time.utc

      abstract def attributes : Hash(String, AnyAttribute) # default to empty hash

      abstract def parent_span : Span?

      abstract def parent_span=(val)

      abstract def initialize(@name)

      abstract def initialize(@name = "", &blk : Event ->)

      abstract def initialize(@name, @attributes : Hash(String, AnyAttribute))

      # This version converts the hash values to AnyAttributes.
      abstract def initialize(@name, attributes : Hash(String, _))

      abstract def attributes=(attr : Hash(String, _))

      abstract def []=(key, value)

      abstract def set_attribute(key, value)

      abstract def [](key)

      abstract def get_attribute(key)

      abstract def time_unix_nano

      abstract def to_protobuf

      abstract def to_json

      abstract def to_json(json : JSON::Builder)
    end
  end
end

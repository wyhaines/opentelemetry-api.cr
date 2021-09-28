require "./attribute"

module OpenTelemetry
  class Event
    property identifier : CSUUID = CSUUID.unique
    property name : String = ""
    property timestamp : Time::Monotonic = Time.monotonic
    property wall_timestamp : Time = Time.utc
    property attributes : Hash(String, Attribute) = Hash(String, Attribute).new
    property parent_span : Span
  end
end

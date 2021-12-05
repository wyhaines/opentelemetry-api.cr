require "./attribute"

module OpenTelemetry
  class Event
    property identifier : CSUUID = CSUUID.unique
    property name : String = ""
    property timestamp : Time::Span = Time.monotonic
    property wall_timestamp : Time = Time.utc
    property attributes : Hash(String, Attribute) = Hash(String, Attribute).new
    property parent_span : Span? = nil
  end
end

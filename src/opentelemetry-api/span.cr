module OpenTelemetry
  # A `Span` represents a single measured timespan, and all data associated
  # with that measurement. A `Span` may nest other `Span` instances.
  class Span
    property name : String = ""
    property start : Time::Span = Time.monotonic
    property wall_start : Time = Time.utc
    property finish : Time::Span? = nil
    property wall_finish : Time? = nil
    property events
  end
end

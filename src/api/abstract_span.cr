require "./sendable"
require "./span/abstract_kind"

module OpenTelemetry
  module API
    # A `Span` represents a single measured timespan, and all data associated
    # with that measurement. A `Span` may nest other `Span` instances.
    abstract class AbstractSpan
      include Sendable

      MATCH = /(?<span_id>[A-Fa-f0-9]{16})/

      def self.validate_id(id : Slice(UInt8))
        # validate_id(id.hexstring)
      end

      def self.validate_id(id : Slice)
        # !!MATCH.match id
      end

      def self.build(name = "")
        span = new(name)
        yield span

        span
      end

      abstract def initialize(@name = "")

      # This is probably a property
      abstract def name : String
      abstract def name=(name : String)

      # This is probably a property
      abstract def start : Time::Span
      abstract def start=(start : Time::Span) # Time::Span = Time.monotonic

      # This is probably a property
      abstract def wall_start : Time
      abstract def wall_start=(wall_start : Time) # Time = Time.utc

      # This is probably a property
      abstract def finish : Time::Span?
      abstract def finish=(finish : Time::Span?) # Time::Span = nil

      # This is probably a property
      abstract def wall_finish : Time?
      abstract def wall_finish=(wall_finish : Time?) # Time = nil

      # This is probably a property
      abstract def events : Array(Event)
      abstract def events=(events : Array(Event))

      # This is probably a property
      abstract def attributes : Hash(String, AnyAttribute)
      abstract def attributes=(attributes : Hash(String, AnyAttribute))

      # This is probably a property
      abstract def parent : Span?
      abstract def parent=(parent : Span?) # Span = nil

      # This is probably a property
      abstract def children : Array(Span)
      abstract def children=(children : Array(Span))

      # This is probably a property
      abstract def context : SpanContext
      abstract def context=(context : SpanContext) # SpanContext = SpanContext.new

      # This is probably a property
      abstract def kind : Kind
      abstract def kind=(kind : Kind) # Kind = Kind::Internal

      # This is probably a property
      abstract def status : Status
      abstract def status=(status : Status) # Status = Status.new

      # This is probably a property
      abstract def is_recording : Bool
      abstract def is_recording=(is_recording : Bool) # Bool = true

      abstract def recording?

      abstract def []=(key, value)

      abstract def set_attribute(key, value)

      abstract def [](key)

      abstract def get_attribute(key)

      abstract def add_event(name)

      abstract def add_event(name = "", &blk : Event ->) # yield event to block

      abstract def add_event(name, attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute)

      abstract def id

      abstract def span_id # synonym for #id

      abstract def can_export?

      # Return the Protobuf object for the Span.
      abstract def to_protobuf

      abstract def to_json

      abstract def to_json(json : JSON::Builder)
    end
  end
end

require "../abstract_span"

module OpenTelemetry
  module API
    abstract class AbstractSpan
      enum Kind
        Unspecified = 0
        Internal    = 1
        Server      = 2
        Client      = 3
        Producer    = 4
        Consumer    = 5
      end
    end
  end
end

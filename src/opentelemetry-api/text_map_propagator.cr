module OpenTelemetry
  # An `OpenTelemetry::Propagator` encapsulates common behavior for typical
  # propagators. Propagators are used to carry and transfer state, typically
  # via either a TraceContext or via Baggage. This class will be subclassed
  # to provide additional specific behavior to conform with the specs for
  # the relevant type of propagator.
  abstract class TextMapPropagator
    @store : Hash(String, String) = {} of String => String

    abstract def inject(carrier, context : Context)
    abstract def extract
    abstract def fields

    def [](key)
      @store[key]
    end

    def []=(key, value)
      @store[key] = value
    end
  end
end

require "./propagation/**"

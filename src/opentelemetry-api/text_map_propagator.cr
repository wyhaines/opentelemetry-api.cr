module OpenTelemetry
  # An `OpenTelemetry::Propagator` encapsulates common behavior for typical
  # propagators. Propagators are used to carry and transfer state, typically
  # via either a TraceContext or via Baggage. This class will be subclassed
  # to provide additional specific behavior to conform with the specs for
  # the relevant type of propagator.
  abstract class TextMapPropagator
    abstract def inject(carrier, context : Context)
    abstract def extract(carrier, context : Context)
    abstract def fields
  end
end

require "./propagation/**"

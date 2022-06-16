require "./abstract_text_map_propagator"

module OpenTelemetry::API
  struct TextMapPropagator < AbstractTextMapPropagator
    def inject(carrier, context : OpenTelemetry::Context)
    end

    def extract(carrier, context : OpenTelemetry::Context)
    end

    def fields
    end
  end
end

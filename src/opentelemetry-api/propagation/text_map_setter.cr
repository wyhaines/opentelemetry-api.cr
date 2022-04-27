module OpenTelemetry
  module Propagation
    module TextMapSetter
      def self.set(carrier, key, value)
        carrier[key] = value
      end
    end
  end
end
module OpenTelemetry
  module Propagation
    module TextMapSetter
      def self.set(carrier, key, value)
        carrier[key.to_s] = value.to_s
      end
    end
  end
end

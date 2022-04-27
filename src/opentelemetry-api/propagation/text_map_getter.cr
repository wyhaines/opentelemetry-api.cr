module OpenTelemetry
  module Propagation
    module TextMapGetter
      def self.get(carrier, key)
        carrier[key]
      end

      def keys(carrier)
        carrier.keys
      end
    end
  end
end

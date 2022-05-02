module OpenTelemetry
  module Propagation
    module TextMapGetter
      def self.get(carrier, key)
        carrier[key]?.to_s
      end

      def keys(carrier)
        carrier.keys
      end
    end
  end
end

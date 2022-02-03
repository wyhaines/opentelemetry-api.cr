require "../instrument"

module OpenTelemetry
  class Instrument
    class Counter < Instrument
      alias NumberClasses = UInt64.class | Float64.class

      def initialize(name, unit = "", variant : NumberClasses = UInt64, description = "")
        super(name, "counter", unit, description)
      end

      def add(value : Int::Unsigned | Float, attributes : Hash(String, ValueTypes)? = nil, labels : Hash(String, String)? = nil)
      end
    end
  end
end

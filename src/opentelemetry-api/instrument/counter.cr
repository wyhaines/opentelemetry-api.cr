require "../instrument"

module OpenTelemetry
  class Instrument
    class Counter < Instrument
      getter counter : Int::Signed | Int::Unsigned | Float32 | Float64
      def initialize(name, unit = "", variant : Symbol = :int32, description = "")
        super(name, "counter", unit, description)
        @counter = case variant.class
        when Float32, Float64
          0.0
        else
          0
        end
      end

      def add()
      end
    end
  end
end
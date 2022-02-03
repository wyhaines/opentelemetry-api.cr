module OpenTelemetry
  class Meter
    class DuplicateInstrumentError < Exception
    end

    class InstrumentNameError < Exception
    end

    class InstrumentUnitError < Exception
    end
  end
end

module OpenTelemetry
  abstract class Exporter
    abstract def export(traces : Array(Trace))

    def export(trace : Trace)
      export [trace]
    end
  end

  class NullExporter < Exporter
    def export(traces : Array(Trace))
    end
  end

  class StdOutExporter < Exporter
    def export(traces : Array(Trace))
    end
  end
end

require "./exporters/*"

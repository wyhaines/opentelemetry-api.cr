module OpenTelemetry
  abstract class Exporter
    abstract def export(traces : Array(Trace))

    def export(trace : Trace)
      export [trace]
    end
  end
end

require "./exporters/*"

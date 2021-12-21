module OpenTelemetry
  class Exporter
    class Stdout < Base
      def export(traces : Array(Trace))
      end
    end
  end
end

module OpenTelemetry
  class Exporter
    # This implements an exporter that simply eats data, sending it into oblivion.
    class Null < Exporter
      def export(traces : Array(Trace))
      end
    end
  end
end
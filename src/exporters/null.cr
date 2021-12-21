require "./unbuffered_exporter"
module OpenTelemetry
  class Exporter
    # This implements an exporter that simply eats data, sending it into oblivion.
    # It will, however, log what it consumes if compiled with -DDEBUG.
    class Null
      include UnbufferedExporter

      def export(elements : Array(Element))
        
      end

      def handle(element)
      end
    end
  end
end

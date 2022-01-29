require "./unbuffered_exporter"

module OpenTelemetry
  class Exporter
    class Base
      include UnbufferedExporter

      # def export(elements : Array(Element))
      #   raise NotImplementedError.new("Exporter::Abstract.export not implemented; this class is not intended to be used externally")
      # end

      def handle(element)
        raise NotImplementedError.new("Exporter::Abstract.handle not implemented; this class is not intended to be used externally")
      end
    end
  end
end

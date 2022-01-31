require "./buffered_exporter"

module OpenTelemetry
  class Exporter
    class BufferedBase
      include BufferedExporter

      # def export(elements : Array(Element))
      #   raise NotImplementedError.new("Exporter::Abstract.export not implemented; this class is not intended to be used externally")
      # end

      def handle(elements : Array(Elements))
        raise NotImplementedError.new("Exporter::Abstract.handle not implemented; this class is not intended to be used externally")
      end
    end
  end
end

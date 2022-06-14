require "./unbuffered_exporter"

module OpenTelemetry
  class Exporter
    class Base
      include UnbufferedExporter

      # def export(elements : Array(Element))
      #   raise NotImplementedError.new("Exporter::Abstract.export not implemented; this class is not intended to be used externally")
      # end

      def handle(elements : Array(Elements))
        raise NotImplementedError.new("Exporter::Abstract.handle not implemented; this class is not intended to be used externally")
      end

      macro method_missing(call)
        macro_debug!("Method missing: {{ call.name }}")
        (raise NotImplementedError.new([{{ @type.id.stringify }}, "{{ call.name.id }} not implemented"].join("#")))
      end
    end
  end
end

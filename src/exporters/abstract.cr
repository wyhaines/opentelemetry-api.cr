module OpenTelemetry
  class Exporter
    # :nodoc:
    class Abstract < Exporter
      # This class exists only for internal use.
      def export(traces : Array(Trace))
        raise NotImplementedError, "Exporter::Abstract.export not implemented; this class is not intended to be used externally"
      end
    end
  end
end

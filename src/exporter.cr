module OpenTelemetry
  abstract class Exporter
  end

  # :nodoc:
  class AbstractExporter < Exporter
    # This class exists only for internal use.
  end

  class NullExporter < Exporter
  end
end

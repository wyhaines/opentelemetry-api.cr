module OpenTelemetry
  abstract class Exporter
  end

  class NullExporter < Exporter
  end
end

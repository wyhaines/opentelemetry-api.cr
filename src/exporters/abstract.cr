require "./base"

module OpenTelemetry
  class Exporter
    # :nodoc:
    # This class exists only for internal use.
    class Abstract < Base
      include UnbufferedExporter
    end
  end
end

require "./opentelemetry-api/trace"
require "./exporters/*"

module OpenTelemetry
  class Exporter
    # As other data types, like metrics or logs are added, expand this aliase
    # to be a union that supports them, as well.
    alias Elements = Trace
    {% begin %}
      # Use the list of things that are known to _not_ be exporters in order to
      # to build a list of all of the known exporters.

      {%
        not_exporters = ["UnbufferedExporter", "BufferedExporter", "Base", "BufferedBase", "Elements"]
        exporters = @type.constants.map(&.stringify).reject { |exp| not_exporters.includes?(exp) }
        last_in_list = exporters.last
      %}
      # The list of known exporters is used in a few places, so create an alias for that type union.
      alias Exporters = {{ exporters.map { |exp| "Exporter::#{exp.id}".id }.join(" | ").id }}
      getter exporter : Exporters
      getter variant : String

      # By building the constructors with macros, the available exporters can be expanded
      # independently of the main codebase. So long as the class is required before this
      # class, so that it is already defined in the `OpenTelemetry::Exporter::*` namespace,
      # it will be accounted for in the contructors here. It, however, is up to the
      # developers of any exporters to ensure that they choose a name which doesn't conflict
      # with one already defined in the `OpenTelemetry::Exporter::*` namespace.
      def initialize(variant : String | Symbol) : Exporters
        @variant = variant.to_s.downcase
        case @variant
        {% for exporter in exporters %}
        {{ exporter == last_in_list ? "else".id : "when".id }} {{ exporter.downcase }}
          @exporter = Exporter::{{ exporter.id }}.new do |obj|
            yield obj
          end
        {% end %}
        end
      end

      def initialize(variant : String | Symbol = :null, *args, **kwargs)
        @variant = variant.to_s.downcase
        case @variant
        {% for exporter in exporters %}
        {{ exporter == last_in_list ? "else".id : "when".id }} {{ exporter.downcase }}
          @exporter = Exporter::{{ exporter.id }}.new(*args, **kwargs)
        {% end %}
        end
      end
    {% end %}

    def export(elements : Array(Elements))
      @exporter.export(elements)
    end

    def export(element : Elements)
      @exporter.export(element)
    end
  end
end

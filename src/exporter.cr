module OpenTelemetry
  class Exporter
    # As other data types, like metrics or logs are added, expand this aliase
    # to be a union that supports them, as well.
    alias Elements = Trace
    getter exporter : Exporter::Base = Exporter::Abstract.new

    def initialize(variant : String | Symbol = :null)
      case variant.to_s.downcase
      when "null"
        @exporter = Exporter::Null.new
      when "abstract"
        @exporter = Exporter::Abstract.new
      end
    end

    def export(elements : Array(Elements))
      @exporter.export(elements)
    end

    def export(element : Elements)
      @exporter.export(element)
    end
  end
end

require "./exporters/*"

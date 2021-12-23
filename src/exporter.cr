require "./opentelemetry-api/trace"

module OpenTelemetry
  class Exporter
    # As other data types, like metrics or logs are added, expand this aliase
    # to be a union that supports them, as well.
    alias Elements = Trace
    getter exporter : Exporter::Base | Exporter::BufferedBase = Exporter::Abstract.new

    def initialize(variant : String | Symbol = :null, *args, **kwargs, &blk : Exporter::Base | Exporter::BufferedBase ->)
      case variant.to_s.downcase
      when "null"
        @exporter = Exporter::Null.new
      when "abstract"
        @exporter = Exporter::Abstract.new
      when "stdout"
        @exporter = Exporter::Stdout.new
      when "http"
        @exporter = Exporter::Http.new
      when "grpc"
        @exporter = Exporter::Grpc.new
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

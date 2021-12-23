require "./opentelemetry-api/trace"

module OpenTelemetry
  class Exporter
    # As other data types, like metrics or logs are added, expand this aliase
    # to be a union that supports them, as well.
    alias Elements = Trace
    getter exporter : Exporter::Base | Exporter::BufferedBase = Exporter::Abstract.new

    def initialize(variant : String | Symbol = :null, *args, **kwargs)
      case variant.to_s.downcase
      when "null"
        @exporter = Exporter::Null.new(*args, **kwargs)
      when "abstract"
        @exporter = Exporter::Abstract.new(*args, **kwargs)
      when "stdout"
        @exporter = Exporter::Stdout.new(*args, **kwargs)
      when "http"
        @exporter = Exporter::Http.new(*args, **kwargs)
      when "grpc"
        @exporter = Exporter::Grpc.new(*args, **kwargs)
      end
    end

    def initialize(variant : String | Symbol = :null, &blk : Exporter::Base? | Exporter::BufferedBase?)
      case variant.to_s.downcase
      when "http"
        @exporter = Exporter::Http.new do
          yield self
        end
      when "grpc"
        @exporter = Exporter::Grpc.new do
          yield self
        end
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

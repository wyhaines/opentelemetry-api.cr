require "./opentelemetry-api/trace"

module OpenTelemetry
  class Exporter
    # As other data types, like metrics or logs are added, expand this aliase
    # to be a union that supports them, as well.
    alias Elements = Trace
    getter exporter : Exporter::Base | Exporter::BufferedBase = Exporter::Abstract.new

    # TODO: Build this using macros, so that if other exporters are added, the
    # code self-assembles to know about them and add access to them. This would
    # make the exporter system easily pluggable just by including another shard.

    def initialize(variant : String | Symbol = :null, &block : Exporter::Http ->)
      case variant.to_s.downcase
      when "http"
        @exporter = Exporter::Http.new(&block)
      end
    end

    def initialize(variant : String | Symbol = :null, &block : Exporter::GRPC ->)
      case variant.to_s.downcase
      when "grpc"
        @exporter = Exporter::GRPC.new(&block)
      end
    end

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
        @exporter = Exporter::GRPC.new(*args, **kwargs)
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

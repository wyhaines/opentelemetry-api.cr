require "./id_generator/*"

module OpenTelemetry

  struct AbstractIdGenerator < IdGenerator::Base
    def trace_id; super; end
    def span_id; super; end
  end

  struct IdGenerator
    @generator : OpenTelemetry::IdGenerator::Base

    def initialize(variant = "unique")
      case variant.downcase
      # TODO: generate this via a macro
      when "unique"
        @generator = OpenTelemetry::IdGenerator::Unique.new
      when "random"
        @generator = OpenTelemetry::IdGenerator::Random.new
      else
        raise "unknown variant #{variant}"
      end
    end

    def trace_id
      @generator.trace_id
    end

    def span_id
      @generator.span_id
    end
  end
end

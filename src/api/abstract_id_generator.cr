require "./id_generator/abstract_base"

module OpenTelemetry
  module API
    abstract struct AbstractIdGenerator
      abstract def initialize(variant : String | Symbol = "unique")

      abstract def generator : AbstractIdGenerator::AbstractBase

      abstract def trace_id

      abstract def span_id

      def self.trace_id
        generator.trace_id
      end

      def self.span_id
        generator.span_id
      end
    end
  end
end

require "./abstract_id_generator"

module OpenTelemetry
  module API
    struct IdGenerator < AbstractIdGenerator
      getter generator : OpenTelemetry::API::IdGenerator::Base
      class_property generator : OpenTelemetry::API::IdGenerator::Base = OpenTelemetry::API::IdGenerator::Base.new

      def initialize(variant : String | Symbol = "unique")
        @generator = OpenTelemetry::API::IdGenerator::Base.new
      end

      def trace_id
        @generator.trace_id
      end

      def span_id
        @generator.span_id
      end

      def self.trace_id
        generator.trace_id
      end

      def self.span_id
        generator.span_id
      end
    end
  end
end

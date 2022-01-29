require "./buffered_base"

module OpenTelemetry
  class Exporter
    class Stdout < BufferedBase

      def initialize
        pp "stdout unconfigured"
      end

      def initialize
        pp "stdout configured"
        yield self
        start
      end

      def handle(elements : Array(Elements))
        elements.each do |element|
          puts element.to_json
        end
      end
    end
  end
end

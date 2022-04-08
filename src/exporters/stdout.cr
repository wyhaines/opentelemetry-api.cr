require "./buffered_base"

module OpenTelemetry
  class Exporter
    class Stdout < Base
      def handle(elements : Array(Elements))
        elements.each do |element|
          puts element.to_json
        end
      end
    end
  end
end

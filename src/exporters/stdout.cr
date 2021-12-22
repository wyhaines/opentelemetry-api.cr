module OpenTelemetry
  class Exporter
    class Stdout < BufferedBase
      def handle(elements : Array(Elements))
        elements.each do |element|
          puts element.to_json
        end
      end
    end
  end
end

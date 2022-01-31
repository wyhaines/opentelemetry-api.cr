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

      def start
        spawn loop_and_receive
      end

      def loop_and_receive
        loop do
          while element = @buffer.receive?
            handle element
          end
          sleep 0.01
        end
      end

      def handle(elements : Array(Elements))
        elements.each do |element|
          puts element.to_json
        end
      end
    end
  end
end

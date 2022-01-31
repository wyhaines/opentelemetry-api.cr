module OpenTelemetry
  class Exporter
    # This module provides the base implementation for building exporters. It
    # provides a Channel into which data elements to be exported are sent. It
    # also defines a `start` method that will create a fiber which will listen
    # on this channel for data waiting to be exported. That fiber will consume
    # the element, and pass it to a `handle` method for actual dispatch.
    # It is expected that subclasses will override at least the `handle` method
    # with their own functionality.
    module UnbufferedExporter
      @buffer : Channel(Elements) = Channel(Elements).new

      def initialize
        pp "UnbufferedExporter.initialize"
        start
      end

      def initialize
        pp "UnbufferedExporter.initialize configured"
        yield self
        start
      end

      def export(elements : Array(Elements))
        elements.each do |element|
          @buffer.send element
        end
      end

      def export(element : Elements)
        @buffer.send element
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

      def handle(element)
        handle [element]
      end

      abstract def handle(elements : Array(Elements))
    end
  end
end

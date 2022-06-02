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
      @reap_semaphore : NBChannel(Bool) = NBChannel(Bool).new
      @reaped : Bool = false

      def do_reap
        @reap_semaphore.send(true)
      end

      def initialize
        start
      end

      def initialize
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

      def reaped?
        if @reaped || @reap_semaphore.receive?
          @reaped = true
        end

        @reaped
      end

      def loop_and_receive
        loop do
          while element = @buffer.receive?
            handle element
          end

          break if reaped?
          sleep 0.01
        end
      end

      @[AlwaysInline]
      def inject_telemetry_attributes(element)
        element["telemetry.sdk.name"] = "opentelemetry"
        element["telemetry.sdk.language"] = "crystal"
        element["telemetry.sdk.version"] = OpenTelemetry::VERSION
      end

      @[AlwaysInline]
      def handle(element)
        inject_telemetry_attributes element
        handle [element]
      end

      abstract def handle(elements : Array(Elements))
    end
  end
end

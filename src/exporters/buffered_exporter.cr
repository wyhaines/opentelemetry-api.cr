require "nbchannel"
require "./unbuffered_exporter"

module OpenTelemetry
  class Exporter
    # A BufferedExporter provides a channel that can receive data to export,
    # defines a `start` method that will spawn a fiber to consume data that
    # enters the channel, and a `handle` method that will handle each data
    # element as it is received.
    module BufferedExporter
      include UnbufferedExporter

      buffer : NBChannel(Elements) = NBChannel(Elements).new
      property batch_size = 100
      property batch_latency = 5
      property batch_interval = 0.05

      def loop_and_receive
        elements = [] of Element
        mark = Time.monotonic
        loop do
          # Consume elements into an internal buffer until the buffer has reached
          # the maximum size for a processing batch, or there is nothing left to
          # consume.
          while elements.size < @batch_size && (element = @buffer.receive?)
            elements << element
          end

          # If the internal buffer has reached the processing threshold size, or
          # if it has been longer than the batch_latency in seconds, then handle
          # each of the elements.
          if elements.size >= @batch_size || Time.monotonic - mark >= @batch_latency
            handle(elements)
            elements.clear
            mark = Time.monotonic
          end
        end
      end

      def handle(elements : Array(Element))
        elements.each do |element|
          handle(element)
        end
      end

    end
  end
end

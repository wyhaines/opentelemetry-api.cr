require "nbchannel"

module OpenTelemetry
  class Exporter
    # A BufferedExporter provides a channel that can receive data to export,
    # defines a `start` method that will spawn a fiber to consume data that
    # enters the channel, and a `handle` method that will handle each data
    # element as it is received.
    module BufferedExporter
      include UnbufferedExporter

      @buffer : NBChannel(Elements) = NBChannel(Elements).new
      property batch_threshold = 100
      property batch_latency = 5
      property batch_interval = 0.05

      def loop_and_receive
        elements = [] of Elements
        elements_size = 0
        mark = Time.monotonic
        oldsize = 0
        last_inspect = Time.monotonic
        loop do
          # Consume elements into an internal buffer until the buffer is greater than
          # the threshold size for a processing batch, or there is nothing left to
          # consume.
          while elements_size < @batch_threshold && (element = @buffer.receive?)
            elements << element
            elements_size += element.size
          end

          if oldsize != elements.size || (Time.monotonic - last_inspect).seconds > 1
            oldsize = elements.size
            last_inspect = Time.monotonic
            {% if flag? :DEBUG %}
              puts "#{self.object_id} : #{elements.size} >= #{@batch_threshold} || #{(Time.monotonic - mark).seconds} >= #{@batch_latency}"
            {% end %}
          end
          # If the internal buffer has reached the processing threshold size, or
          # if it has been longer than the batch_latency in seconds, then handle
          # each of the elements.
          if elements.size >= @batch_threshold || (Time.monotonic - mark).seconds >= @batch_latency
            handle(elements)
            elements.clear
            elements_size = 0
            mark = Time.monotonic
          end

          break if reaped?
          sleep 0.01
        end
      end
    end
  end
end

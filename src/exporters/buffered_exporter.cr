require "nbchannel"

module OpenTelemetry
  class Exporter
    # A BufferedExporter provides a channel that can receive data to export,
    # defines a `start` method that will spawn a fiber to consume data that
    # enters the channel, and a `handle` method that will handle each data
    # element as it is received.
    module BufferedExporter
      @otel_buffer : NBChannel(Trace) = NBChannel(Trace).new
    end
  end
end
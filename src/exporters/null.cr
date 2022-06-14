require "./base"
require "colorize"

module OpenTelemetry
  class Exporter
    # This implements an exporter that simply eats data, sending it into oblivion.
    # It will, however, log what it consumes if compiled with -DDEBUG.
    class Null < Base
      def handle(elements : Array(Elements))
        {% begin %}
          {% if ::Debug::ACTIVE %}
            elements.each do |element|
              output = element.to_json
              debug!(output)
            end
          {% end %}
        {% end %}
      end
    end
  end
end

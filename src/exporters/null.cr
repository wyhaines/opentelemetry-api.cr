require "./base"
require "colorize"

module OpenTelemetry
  class Exporter
    # This implements an exporter that simply eats data, sending it into oblivion.
    # It will, however, log what it consumes if compiled with -DDEBUG.
    class Null < Base
      def handle(element)
        {% begin %}
        {% if flag? :DEBUG %}
        output = element.to_json
        puts "\n#{"DEBUG - #{Time.local}:\n".colorize(:green)} #{output}"
        {% end %}
        {% end %}
      end
    end
  end
end

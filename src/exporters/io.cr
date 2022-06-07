require "./buffered_base"
require "io/memory"

module OpenTelemetry
  class Exporter
    class IO < Base
      property io : ::IO | ::IO::Memory | Nil

      def initialize(@io : ::IO | ::IO::Memory = ::IO::Memory.new, *_junk, **_kwjunk)
        start
      end

      def initialize
        yield self
        start
      end

      def handle(elements : Array(Elements))
        if io_not_nil = io
          elements.each do |element|
            io_not_nil << element.to_json
          end
        end
      end
    end
  end
end

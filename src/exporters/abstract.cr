require "./base"

module OpenTelemetry
  class Exporter
    # :nodoc:
    # This class exists only for internal use.
    class Abstract < Base
      def finalize
        do_reap
      end

      def do_reap
      end
    end
  end
end

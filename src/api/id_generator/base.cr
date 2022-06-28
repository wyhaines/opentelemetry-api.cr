require "./abstract_base"

module OpenTelemetry
  module API
    struct AbstractIdGenerator
      struct Base < AbstractBase
        def trace_id
        end

        def span_id
        end
      end
    end
  end
end

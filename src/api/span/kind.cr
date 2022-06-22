require "./abstract_kind"

module OpenTelemetry
  module API
    class Span < AbstractSpan
      alias Kind = AbstractSpan::Kind
    end
  end
end

module OpenTelemetry
  class Trace
    class InvalidSpanInSpanStackError < Exception
      def initialize(found = nil, expected = nil)
        message = if found && expected
                    "Unexpected Error: Invalid Spans in the Span Stack. Expected #{expected.inspect} but found #{found.inspect}"
                  elsif found
                    "Unexpected Error: Invalid Spans in the Span Stack. Found #{found.inspect}"
                  elsif expected
                    "Unexpected Error: Invalid Spans in the Span Stack. Expected #{expected.inspect}"
                  else
                    "Unexpected Error: Invalid Spans in the Span Stack"
                  end
        super(message)
      end
    end
  end
end

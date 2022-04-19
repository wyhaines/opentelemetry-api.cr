class Exception
  # This adds a flag to an exception, so that underlying code can
  # easily know if this exception has been set in a span status.
  # Otherwise handlers may repeatedly set a whole chain of spans
  # to error state as an exception bubbles up through the span stack.
  property span_status_message_set : Bool = false
end

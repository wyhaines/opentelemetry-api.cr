class Fiber
  property current_span : OpenTelemetry::Span? = nil
  property current_trace : OpenTelemetry::Trace? = nil

  # This permits Fiber instances to be sorted.
  def <=>(val)
    self.object_id <=> val.object_id
  end
end

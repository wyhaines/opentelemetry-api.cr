class Fiber
  property current_span : OpenTelemetry::Span? = nil
  
  def <=>(val)
    self.object_id <=> val.object_id
  end
end

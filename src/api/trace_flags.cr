module OpenTelemetry
  module API
    @[Flags]
    enum TraceFlags
      Sampled = 0x01
    end
  end
end

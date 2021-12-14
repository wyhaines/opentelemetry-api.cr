module OpenTelemetry
  abstract struct IdGeneratorBase
    def self.trace_id
      Bytes.random(16)
    end

    def self.span_id
      Bytes.random(8)
    end
  end
end
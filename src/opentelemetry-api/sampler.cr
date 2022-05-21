module OpenTelemetry
  # All Samplers should inherit from and implement this interface.
  abstract struct Sampler
    # This should probably be overridden with a specific, appropriate name.
    def description
      self.class.name
    end
  end
end

require "./samplers/*"

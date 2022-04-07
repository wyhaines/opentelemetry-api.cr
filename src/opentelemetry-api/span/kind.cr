module OpenTelemetry
  class Span
    enum Kind
      Client
      Server
      Producer
      Consumer
      Internal
      Unspecified
    end
  end
end

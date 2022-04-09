module OpenTelemetry
  class Span
    enum Kind
      Unspecified = 0
      Internal    = 1
      Server      = 2
      Client      = 3
      Producer    = 4
      Consumer    = 5
    end
  end
end

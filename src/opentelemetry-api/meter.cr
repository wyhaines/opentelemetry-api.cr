require "random/pcg32"

module OpenTelemetry
  class Meter
    @[ThreadLocal]
    @@prng = Random::PCG32.new
  end
end
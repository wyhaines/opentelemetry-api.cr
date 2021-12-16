require "base"
require "csuuid"
require "random/isaac"
require "crystal/spin_lock"

module OpenTelemetry
  # This ID Generator returns guaranteed unique (within the process) IDs
  # which are chronologically and logically sortable.
  struct IdGenerator::Unique < Base
    @@unique_identifier : Slice(UInt8) = Slice(UInt8).new(3, 0)
    @@mutex = Crystal::SpinLock.new
    @@prng = Random::ISAAC.new

    def self.trace_id
      CSUUID.unique.bytes
    end

    def self.span_id
      @@mutex.sync do
        t = Time.local
        if t.internal_nanoseconds == @@unique_seconds_and_nanoseconds[1] &&
            t.internal_seconds == @@unique_seconds_and_nanoseconds[0]
          increment_unique_identifier
        else
          @@unique_seconds_and_nanoseconds = {t.internal_seconds, t.internal_nanoseconds}
          @@unique_identifier = @@prng.random_bytes(6)
        end
  
        new(
          @@unique_seconds_and_nanoseconds[0],
          @@unique_seconds_and_nanoseconds[1],
          @@unique_identifier
        )
      end
    end

      # :nodoc:
    def self.increment_unique_identifier
      2.downto(0) do |position|
        new_byte_value = @@unique_identifier[position] &+= 1
        break unless new_byte_value == 0
      end

      @@unique_identifier
    end
  end
end
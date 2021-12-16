require "csuuid"
require "random/isaac"
require "crystal/spin_lock"
require "./base"

module OpenTelemetry
  # This ID Generator returns guaranteed unique (within the process) IDs
  # which are chronologically and logically sortable.
  struct IdGenerator::Unique < IdGenerator::Base
    @prng : ::Random::ISAAC = ::Random::ISAAC.new
    @unique_identifier : Slice(UInt8) = Slice(UInt8).new(3, 0)
    @mutex : Crystal::SpinLock = Crystal::SpinLock.new

    def trace_id
      CSUUID.unique.bytes
    end

    def span_id
      span_bytes = Slice(UInt8).new(8, 0)
      @mutex.sync do
        t = Time.local
        increment_unique_identifier
        seconds_buffer = Slice(UInt8).new(6, 0)
        IO::ByteFormat::BigEndian.encode(t.internal_seconds, seconds_buffer)
        span_bytes[0, 5].copy_from(seconds_buffer[1, 5])
        span_bytes[5, 3].copy_from(@unique_identifier)
      end
      span_bytes
    end

    # :nodoc:
    def self.increment_unique_identifier
      2.downto(0) do |position|
        new_byte_value = @unique_identifier[position] &+= 1
        break unless new_byte_value == 0
      end

      @unique_identifier
    end
  end
end

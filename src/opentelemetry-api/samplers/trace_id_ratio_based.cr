require "digest/crc32"
require "big"

module OpenTelemetry
  # This sampler will only record a subset of the total number of traces. It can be initialized
  # with either a decimal ratio or a fraction. Examples:
  #
  # ```
  # # Record 10% of the total traces
  # sampler = OpenTelemetry::Sampler::TraceIdRatioBased.new(0.1)
  # ```
  #
  # ```
  # # Record 50% of the total traces
  # sampler = OpenTelemetry::Sampler::TraceIdRatioBased.new(0.5)
  # ```
  #
  # ```
  # # Record 1/30th of the total traces
  # sampler = OpenTelemetry::Sampler::TraceIdRatioBased.new(1, 30)
  # ```
  #
  # It uses CRC32 for the hashing/randomization algorithm. CRC32 is
  # dramatically faster than algorithms like MD5 or SHA1, and it
  # produces a more uniform distribution of the bits for trace id input
  # data than does any of the readily available cryptographic hashing
  # algorithms. It is surprisingly good for this purpose.
  struct Sampler::TraceIdRatioBased < InheritableSampler
    BlankId = Slice(UInt8).new(16, 0)
    @ratio : Float64 = 1.0
    getter! description : String

    def initialize(arg = nil)
      initialize_impl arg.to_s.to_f64
    rescue
      initialize_impl 0_f64
    end

    def initialize(ratio : Float | String)
      initialize_impl(ratio.to_f64)
    end

    def initialize(numerator : Int, denominator : Int)
      initialize_impl(BigRational.new(numerator, denominator).to_f64)
    end

    def initialize_impl(@ratio)
      @description = finish_initialization
    end

    private def finish_initialization
      normalize_ratio
      "TraceIdRatioBased{#{@ratio}}"
    end

    private def normalize_ratio
      @ratio = 1 if @ratio > 1
      @ratio = 0 if @ratio < 0
    end

    private def should_sample_impl(context, name, trace_id, kind, attributes, links) : SamplingResult
      tid = trace_id == BlankId ? context.trace_id : trace_id
      if (Digest::CRC32.checksum(tid) / 4294967295_u32) <= @ratio
        SamplingResult.new(SamplingResult::Decision::RecordAndSample)
      else
        SamplingResult.new(SamplingResult::Decision::Drop)
      end
    end
  end
end

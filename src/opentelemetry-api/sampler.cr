module OpenTelemetry
  # All Samplers should inherit from and implement this interface.
  abstract struct Sampler
    def should_sample(
      context : SpanContext,
      name : String,
      trace_id : Slice(UInt8)? = nil,
      kind : Kind = Kind::Internal,
      attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute,
      links : Nil = nil # Not implemented yet
    ) : SamplingResult
      validate(context, name, trace_id, kind, attributes, links)

      should_sample_impl(context, name, trace_id, kind, attributes, links)
    end

    private abstract def should_sample_impl(context, name, trace_id, kind, attributes, links) : SamplingResult

    # This should probably be overridden with a specific, appropriate name.
    def description
      self.class.name
    end
  end
end

require "./sampler/sampling_result"
require "./samplers/*"

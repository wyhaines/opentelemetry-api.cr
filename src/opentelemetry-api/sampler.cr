module OpenTelemetry
  # All Samplers should inherit from and implement this interface.
  abstract struct Sampler
    def should_sample(
      context : SpanContext,
      name : String = "",
      trace_id : Slice(UInt8)? = nil,
      kind : OpenTelemetry::Span::Kind = OpenTelemetry::Span::Kind::Internal,
      attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute,
      links : Nil = nil # Not implemented yet
    ) : SamplingResult
      trace_id = validate(context, name, trace_id, kind, attributes, links)

      should_sample_impl(context, name, trace_id, kind, attributes, links)
    end

    private def validate(context, name, trace_id, kind, attributes, links)
      if trace_id
        raise ArgumentError.new("The trace id in the span context (#{context.trace_id}) must match the provided trace_id (#{trace_id})") unless context.trace_id == trace_id
        trace_id
      else
        context.trace_id
      end
    end

    # Override this with sampling decision making logic relevant to the type of sampler being implemented.
    private abstract def should_sample_impl(context, name, trace_id, kind, attributes, links) : SamplingResult

    # This should probably be overridden with a specific, appropriate name.
    def description
      self.class.name
    end

    # Crystal doesn't tend to yuse `get_*` names, but this name is provided as an alias for `description` to be more spec compliant,
    # as it request `getDescription` or a close equivalent.
    def get_description
      description
    end
  end
end

require "./sampler/sampling_result"
require "./samplers/*"

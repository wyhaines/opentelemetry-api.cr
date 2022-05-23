module OpenTelemetry
  struct Sampler::ParentBased < Sampler
    getter description : String
    def initialize(
      @root : InheritableSampler,
      @remote_parent_sampled : InheritableSampler = AlwaysOn.new,
      @remote_parent_not_sampled : InheritableSampler = AlwaysOff.new,
      @local_parent_sampled : InheritableSampler = AlwaysOn.new,
      @local_parent_not_sampled : InheritableSampler = AlwaysOff.new
    )
      @description = "ParentBased{root=#{@root.description}, remote_parent_sampled=#{@remote_parent_sampled.description}, remote_parent_not_sampled=#{@remote_parent_not_sampled.description}, local_parent_sampled=#{@local_parent_sampled.description}, local_parent_not_sampled=#{@local_parent_not_sampled}}"
    end

    private def should_sample_impl(context, name, trace_id, kind, attributes, links) : SamplingResult
      if parent_id = context.parent_id
        @root
      elsif context.remote? && context.trace_flags.sampled?
        @remote_parent_sampled
      elsif context.remote? && !context.trace_flags.sampled?
        @remote_parent_not_sampled
      elsif !context.remote? && context.trace_flags.sampled?
        @local_parent_sampled
      else
        @local_parent_not_sampled
      end.should_sample(context, name, trace_id, kind, attributes, links)
    end
  end
end
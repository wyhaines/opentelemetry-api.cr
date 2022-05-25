module OpenTelemetry
  struct Sampler::ParentBased < Sampler
    getter description : String

    def initialize(arg = nil)
      if arg.is_a? InheritableSampler
        arg = arg.class.name
      end

      if arg
        pre_root = Provider::Configuration.get_sampler_class_from_name(arg)
        if pre_root.is_a?(InheritableSampler)
          @root = pre_root
        else
          @root = AlwaysOn.new
        end
      else
        @root = AlwaysOn.new
      end
      @remote_parent_sampled = AlwaysOn.new
      @remote_parent_not_sampled = AlwaysOff.new
      @local_parent_sampled = AlwaysOn.new
      @local_parent_not_sampled = AlwaysOff.new
      @description = "ParentBased{root=#{@root.description}, remote_parent_sampled=#{@remote_parent_sampled.description}, remote_parent_not_sampled=#{@remote_parent_not_sampled.description}, local_parent_sampled=#{@local_parent_sampled.description}, local_parent_not_sampled=#{@local_parent_not_sampled}}"
    end

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
      if context.parent_id
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

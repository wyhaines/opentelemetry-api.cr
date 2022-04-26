require "./context/key"
require "splay_tree_map"

module OpenTelemetry
  struct Context
    alias ContextContainer = SplayTreeMap(String, String)

    @@root : Context = Context.new
    @@stack : SplayTreeMap(Fiber, Array(Context)) = SplayTreeMap(Fiber, Array(Context)).new { |h, k| h[k] = [] of Context }

    getter object_id : CSUUID = CSUUID.unique

    def self.stack
      @@stack[Fiber.current]
    end

    def self.current
      stack.empty? ? @@root : stack.last
    end

    def self.create_key
      Key.new
    end

    def self.create_key(name)
      Key.new(name)
    end

    def self.attach(context : Context)
      stack << context
      context.object_id
    end

    def self.attach(entries)
      attach(Context.new(entries))
    end

    # Restores the previous Context associated with the current Fiber.
    # The supplied token is used to check if the call to detach is balanced
    # with a corresponding attach call. A warning is logged if the
    # calls are unbalanced.
    def self.detach(token)
      ctxt = stack
      calls_matched = (token == ctxt.object_id)
      # OpenTelemetry.handle_error(exception: DetachError.new("calls to detach should match corresponding calls to attach.")) unless calls_matched

      ctxt.pop
      calls_matched
    end

    def self.attach(context : Context)
      token = context.object_id
      stack << context
      yield context
    ensure
      detach(token)
    end

    def self.attach(entries)
      attach(Context.new(entries)) { |ctx| yield ctx }
    end

    # Executes a block with ctx as the current context. It restores
    # the previous context upon exiting.
    def self.with(context : Context)
      attach(context) { |ctx| yield ctx }
    end

    def self.with(entries)
      self.with(Context.new(entries)) { |ctx| yield ctx }
    end

    # Execute a block in a new context with key set to value. Restores the
    # previous context after the block executes.
    def self.with(key, value)
      ctx = current[key] = value
      token = attach(ctx)
      yield ctx, value
    ensure
      detach(token)
    end

    def self.with(key, value)
      self.with(key, value) { |ctx, val| yield ctx, val }
    end

    # Execute a block in a new context where its values are merged with the
    # incoming values. Restores the previous context after the block executes.

    # @param [String] key The lookup key
    # @param [Hash] values Will be merged with values of the current context
    #  and returned in a new context
    # @param [Callable] Block to execute in a new context
    # @yield [context, values] Yields the newly created context and values
    #   to the block
    def self.with(values)
      ctx = current.dup.merge(values)
      token = attach(ctx)
      yield ctx, values
    ensure
      detach(token)
    end

    def self.with(key, values)
      self.with(key, values) { |ctx, val| yield ctx, val }
    end

    def self.[](key)
      current[key]
    end

    def self.[]?(key)
      current[key]?
    end

    def self.value(key)
      self[key]
    end

    def self.value?(key)
      self[key]?
    end

    def self.[]=(key, value)
      current[key] = value
    end

    def self.set_value(key, value)
      self[key] = value
    end

    def self.clear
      stack.clear
    end

    def initialize
      @entries = ContextContainer.new
    end

    def initialize(entries : ContextContainer)
      @entries = entries.dup
    end

    def initialize(entries)
      @entries = ContextContainer.new

      entries.each do |k, v|
        @entries[k.to_s] = v.to_s
      end
    end

    def value(key)
      self[key]
    end

    def value?(key)
      self[key]?
    end

    def [](key)
      @entries[key]
    end

    def []?(key)
      @entries[key]?
    end

    def set_value(key, value)
      self[key] = value
    end

    def []=(key, value)
      @entries[key] = value
    end

    def merge(other_entries)
      @entries.merge(other_entries)
    end
  end
end

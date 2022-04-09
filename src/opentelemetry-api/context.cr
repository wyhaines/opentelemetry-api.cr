require "./context/key"
require "splay_tree_map"

module OpenTelemetry
  struct Context
    alias ContextContainer = SplayTreeMap(OpenTelemetry::Context::Key, String)

    @@root : SplayTreeMap(Key, String) = SplayTreeMap(Key, String).new
    @@stack : SplayTreeMap(Fiber, Array(SplayTreeMap(Key, String))) = SplayTreeMap(Fiber, Array(SplayTreeMap(Key, String))).new { |h, k| h[k] = [] of SplayTreeMap(Key, String) }

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

    def self.attach(context)
      stack << context
      context.object_id
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

    # Executes a block with ctx as the current context. It restores
    # the previous context upon exiting.
    def self.with_current(ctx)
      token = attach(ctx)
      yield ctx
    ensure
      detach(token)
    end

    # Execute a block in a new context with key set to value. Restores the
    # previous context after the block executes.
    def self.with_value(key, value)
      ctx = current.set_value(key, value)
      token = attach(ctx)
      yield ctx, value
    ensure
      detach(token)
    end

    # Execute a block in a new context where its values are merged with the
    # incoming values. Restores the previous context after the block executes.

    # @param [String] key The lookup key
    # @param [Hash] values Will be merged with values of the current context
    #  and returned in a new context
    # @param [Callable] Block to execute in a new context
    # @yield [context, values] Yields the newly created context and values
    #   to the block
    def self.with_values(values)
      ctx = current.set_values(values)
      token = attach(ctx)
      yield ctx, values
    ensure
      detach(token)
    end

    #   # Returns the value associated with key in the current context
    #   #
    #   # @param [String] key The lookup key
    #   def self.value(key)
    #     current.value(key)
    #   end

    def self.clear
      stack.clear
    end

    #   def self.empty
    #     new(EMPTY_ENTRIES)
    #   end

    #     # -----------------------------------
    #   def initialize(entries)
    #     @entries = entries.freeze
    #   end

    #   # Returns the corresponding value (or nil) for key
    #   #
    #   # @param [Key] key The lookup key
    #   # @return [Object]
    #   def value(key)
    #     @entries[key]
    #   end

    def [](value)
      stack[value]
    end

    #   # Returns a new Context where entries contains the newly added key and value
    #   #
    #   # @param [Key] key The key to store this value under
    #   # @param [Object] value Object to be stored under key
    #   # @return [Context]
    #   def set_value(key, value)
    #     new_entries = @entries.dup
    #     new_entries[key] = value
    #     Context.new(new_entries)
    #   end

    #   # Returns a new Context with the current context's entries merged with the
    #   #   new entries
    #   #
    #   # @param [Hash] values The values to be merged with the current context's
    #   #   entries.
    #   # @param [Object] value Object to be stored under key
    #   # @return [Context]
    #   def set_values(values)
    #     Context.new(@entries.merge(values))
    #   end

    #   ROOT = empty.freeze
  end
end

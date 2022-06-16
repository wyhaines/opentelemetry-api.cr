require "splay_tree_map"

module OpenTelemetry
  module API
    abstract struct AbstractContext
      alias ContextContainer = SplayTreeMap(String, String)

      # This is assumed to be implemented as a getter with
      # a default value of `CSUUID.unique`.
      abstract def object_id

      def self.stack
        raise NotImplementedError.new("self.stack must be implemented in subclasses")
      end

      def self.current
        raise NotImplementedError.new("self.current must be implemented in subclasses")
      end

      def self.create_key
        raise NotImplementedError.new("self.create_key must be implemented in subclasses")
      end

      def self.create_key(name)
        raise NotImplementedError.new("self.create_key must be implemented in subclasses")
      end

      def self.attach(context : Context)
        raise NotImplementedError.new("self.attach must be implemented in subclasses")
      end

      def self.attach(entries)
        raise NotImplementedError.new("self.attach must be implemented in subclasses")
      end

      # Restores the previous Context associated with the current Fiber.
      # The supplied token is used to check if the call to detach is balanced
      # with a corresponding attach call. A warning is logged if the
      # calls are unbalanced.
      def self.detach(token)
        raise NotImplementedError.new("self.detach must be implemented in subclasses")
      end

      def self.attach(context : Context)
        raise NotImplementedError.new("self.attach must be implemented in subclasses")
      end

      def self.attach(entries)
        raise NotImplementedError.new("self.attach must be implemented in subclasses")
      end

      # Executes a block with ctx as the current context. It restores
      # the previous context upon exiting.
      def self.with(context : Context)
        raise NotImplementedError.new("self.with must be implemented in subclasses")
      end

      def self.with(entries)
        raise NotImplementedError.new("self.with must be implemented in subclasses")
      end

      # Execute a block in a new context with key set to value. Restores the
      # previous context after the block executes.
      def self.with(key, value)
        raise NotImplementedError.new("self.with must be implemented in subclasses")
      end

      def self.with(key, value)
        raise NotImplementedError.new("self.with must be implemented in subclasses")
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
        raise NotImplementedError.new("self.with must be implemented in subclasses")
      end

      def self.with(key, values)
        raise NotImplementedError.new("self.with must be implemented in subclasses")
      end

      def self.[](key)
        raise NotImplementedError.new("self.[] must be implemented in subclasses")
      end

      def self.[]?(key)
        raise NotImplementedError.new("self.[]? must be implemented in subclasses")
      end

      def self.value(key)
        raise NotImplementedError.new("self.value must be implemented in subclasses")
      end

      def self.value?(key)
        raise NotImplementedError.new("self.value? must be implemented in subclasses")
      end

      def self.[]=(key, value)
        raise NotImplementedError.new("self.[]= must be implemented in subclasses")
      end

      def self.set_value(key, value)
        raise NotImplementedError.new("self.set_value must be implemented in subclasses")
      end

      def self.clear
        raise NotImplementedError.new("self.clear must be implemented in subclasses")
      end

      abstract def initialize

      abstract def initialize(entries : ContextContainer)

      abstract def initialize(entries)

      abstract def value(key)

      abstract def value?(key)

      abstract def [](key)

      abstract def []?(key)

      abstract def set_value(key, value)

      abstract def []=(key, value)

      abstract def entries

      abstract def merge(other_entries)
    end
  end
end

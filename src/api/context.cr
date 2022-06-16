require "./context/key"
require "splay_tree_map"
require "csuuid"

module OpenTelemetry
  module API
    struct Context < AbstractContext
      getter object_id : CSUUID = CSUUID.unique

      def self.stack
      end

      def self.current
      end

      def self.create_key
      end

      def self.create_key(name)
      end

      def self.attach(context)
      end

      def self.attach(entries)
      end

      # Restores the previous Context associated with the current Fiber.
      # The supplied token is used to check if the call to detach is balanced
      # with a corresponding attach call. A warning is logged if the
      # calls are unbalanced.
      def self.detach(token)
      end

      def self.attach(context)
      end

      def self.attach(entries)
      end

      # Executes a block with ctx as the current context. It restores
      # the previous context upon exiting.
      def self.with(context)
      end

      def self.with(entries)
      end

      # Execute a block in a new context with key set to value. Restores the
      # previous context after the block executes.
      def self.with(key, value)
      end

      def self.with(key, value)
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
      end

      def self.with(key, values)
      end

      def self.[](key)
      end

      def self.[]?(key)
      end

      def self.value(key)
      end

      def self.value?(key)
      end

      def self.[]=(key, value)
      end

      def self.set_value(key, value)
      end

      def self.clear
      end

      def initialize
      end

      def initialize(entries)
      end

      def initialize(entries)
      end

      def value(key)
      end

      def value?(key)
      end

      def [](key)
      end

      def []?(key)
      end

      def set_value(key, value)
      end

      def []=(key, value)
      end

      def entries
      end

      def merge(other_entries)
      end
    end
  end

  alias Context = API::Context
end

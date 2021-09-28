module OpenTelemetry
  class Context
    struct Key
      getter name : String

      def initialize(@name = CSUUID.unique.to_s, context = nil)

      end

      def value
        get
      end

      def get(context = Context.current)
        context[self]
      end
    end
  end
end

module OpenTelemetry
  struct Context
    struct Key
      getter name : String
      getter id : CSUUID
      getter context : ContextContainer

      def initialize(@name = CSUUID.unique.to_s, @context = Context.current, @id = CSUUID.unique)
      end

      def value
        get
      end

      def get(context = Context.current)
        context[self]
      end

      def <=>(val)
        id <=> val.id
      end
    end
  end
end

module OpenTelemetry
  struct Context
    struct Key
      getter name : String
      getter id : CSUUID
      getter context : Context

      def initialize(@name = CSUUID.unique.to_s, @context = Context.current, @id = CSUUID.unique)
      end

      def value
        get
      end

      def get(context = Context.current)
        context[self.name]
      end

      def <=>(val)
        id <=> val.id
      end
    end
  end
end

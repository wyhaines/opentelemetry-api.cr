module OpenTelemetry::API
  abstract struct AbstractContext
    abstract struct AbstractKey
      abstract def name : String
      abstract def id : CSUUID
      abstract def context : Context

      abstract def initialize(@name = CSUUID.unique.to_s, @context = Context.current, @id = CSUUID.unique)

      abstract def value

      abstract def get(context = Context.current)

      abstract def <=>(other)
    end
  end
end

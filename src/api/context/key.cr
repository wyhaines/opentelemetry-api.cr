require "./abstract_key"
require "csuuid"

module OpenTelemetry
  module API
    struct Context < AbstractContext
      struct Key < OpenTelemetry::API::AbstractContext::AbstractKey
        include Comparable(Key)

        getter name : String
        getter id : CSUUID
        getter context : Context

        def initialize(@name = CSUUID.unique.to_s, @context = Context.current, @id = CSUUID.unique)
        end

        def value
        end

        def get(context = Context.current)
        end

        def <=>(val)
          id <=> val.id
        end
      end
    end
  end
end

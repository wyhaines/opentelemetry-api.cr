module OpenTelemetry
  module Sendable
    abstract def to_protobuf
    abstract def to_json

    def size
      1
    end
  end
end

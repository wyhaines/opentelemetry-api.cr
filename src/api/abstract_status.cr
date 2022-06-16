module OpenTelemetry
  module API
    abstract struct AbstractStatus
      enum StatusCode
        Unset = 0
        Ok    = 1
        Error = 2
      end

      abstract def initialize(@code = StatusCode::Unset, @message = "")

      abstract def ok!(message = nil)

      abstract def error!(message = nil)

      abstract def unset!(message = nil)

      abstract def pb_status_code

      abstract def to_protobuf

      abstract def to_json

      abstract def to_json(json : JSON::Builder)

      # This is assumed to be implemented as a property in the SDK.
      abstract def code
      abstract def code=(code : StatusCode)

      # This is assumed to be implemented as a property in the SDK.
      abstract def message
      abstract def message=(message : String)
    end
  end
end

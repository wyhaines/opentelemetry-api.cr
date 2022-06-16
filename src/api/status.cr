require "./abstract_status"

module OpenTelemetry
  module API
    struct Status < AbstractStatus
      property code : StatusCode
      property message : String

      alias StatusCode = AbstractStatus::StatusCode

      def initialize(@code = StatusCode::Unset, @message = "")
      end

      def ok!(message = nil)
      end

      def error!(message = nil)
      end

      def unset!(message = nil)
      end

      def pb_status_code
      end

      def to_protobuf
      end

      def to_json
      end

      def to_json(json : JSON::Builder)
      end
    end
  end
end

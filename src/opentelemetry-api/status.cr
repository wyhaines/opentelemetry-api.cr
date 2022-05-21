module OpenTelemetry
  struct Status
    property code : StatusCode
    property message : String

    enum StatusCode
      Unset = 0
      Ok    = 1
      Error = 2
    end

    def initialize(@code = StatusCode::Unset, @message = "")
    end

    def ok!(message = nil)
      @code = StatusCode::Ok
      @message = message if message
    end

    def error!(message = nil)
      @code = StatusCode::Error
      @message = message if message
    end

    def unset!(message = nil)
      @code = StatusCode::Unset
      @message = message if message
    end

    def pb_status_code
      case @code
      when StatusCode::Unset
        Proto::Trace::V1::Status::StatusCode::STATUSCODEUNSET
      when StatusCode::Ok
        Proto::Trace::V1::Status::StatusCode::STATUSCODEOK
      else
        Proto::Trace::V1::Status::StatusCode::STATUSCODEERROR
      end
    end

    def to_protobuf
      OpenTelemetry::Proto::Trace::V1::Status.new(
        message: @message,
        code: pb_status_code
      )
    end

    def to_json
      String.build do |json|
        json << "{\n"
        json << "  \"code\": #{@code.value},\n"
        json << "  \"message\": \"#{@message}\"\n"
        json << "}"
      end
    end
  end
end

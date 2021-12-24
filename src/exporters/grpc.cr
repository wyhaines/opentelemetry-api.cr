require "./http"

module OpenTelemetry
  class Exporter
    class GRPC < Http
      def setup_standard_headers
        @headers = {
          "Content-Type" => "application/grpc-web+proto",
          "Accept"       => "application/grpc-web",
        }
      end

      def generate_payload(request)
        request_payload = request.to_slice

        payload = IO::Memory.new
        # TODO: Support compression
        payload.write_bytes(0_u8)
        payload.write_bytes(request_payload.size, IO::ByteFormat::NetworkEndian)
        payload.write request_payload

        payload.to_slice
      end
    end
  end
end

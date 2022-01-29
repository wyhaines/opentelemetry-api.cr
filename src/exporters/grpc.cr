# This whole exporter is currently commented out because Duo doesn't work well enough,
# so a new HTTP/2 client is being built.

# require "socket"
# require "openssl"
# require "./http"

# module OpenTelemetry
#   class Exporter
#     class GRPC < Http
#       def initialize(endpoint : String? = nil, _headers : HTTP::Headers? = nil, _clients : DB::Pool(HTTP::Client)? = nil)
#         @endpoint_uri = endpoint if endpoint
#         @headers = _headers if _headers
#         if _clients
#           @clients = _clients
#           @clients_are_initialized = true
#         else
#           @clients = uninitialized DB::Pool(Duo::Client)
#         end
#         initialize_client_pool
#         start
#       end

#       def initialize
#         @clients_are_initialized = false
#         @clients = uninitialized DB::Pool(Duo::Client)
#         yield self
#         initialize_client_pool
#         start
#       end

#       def initialize_client_pool
#         return if @clients_are_initialized
#         @clients = DB::Pool(Duo::Client).new do
#           Duo::Client.new(
#             @endpoint_uri.host.to_s,
#             @endpoint_uri.port.as(Int32),
#             true)
#         end
#         @clients_are_initialized = true
#       end

#       def setup_standard_headers(headers)
#         headers[":method"] = "POST"
#         headers[":path"] = "/"
#         headers["user-agent"] = user_agent
#         headers["content-type"] = "application/grpc+proto"
#         headers["accept"] = "application/grpc"

#         @headers.each do |key, value|
#           request.headers[key] = value
#         end
#       end

#       def handle(elements : Array(Elements))
#         puts "GRPC exporter: #{elements.size} elements"
#         batches = collate(elements)
#         pp batches
#         @clients.checkout do |client|
#           puts "got client #{client.inspect}"
#           if !batches[:traces].empty?
#             # TODO: handle errors; retry?
#             puts "POST to #{@endpoint_uri.path} with "
#           end
#         end
#       end

#       def generate_payload(request)
#         request_payload = request.to_slice

#         payload = IO::Memory.new
#         # TODO: Support compression
#         payload.write_bytes(0_u8)
#         payload.write_bytes(request_payload.size, IO::ByteFormat::NetworkEndian)
#         payload.write request_payload

#         puts payload.to_slice.hexstring
#         payload.to_slice
#       end
#     end
#   end
# end

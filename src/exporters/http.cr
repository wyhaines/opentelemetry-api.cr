require "db/pool"
require "http/client"

module OpenTelemetry
  class Exporter
    class Http < BufferedBase
      property clients : DB::Pool(HTTP::Client)
      property headers : HTTP::Headers = HTTP::Headers.new
      property endpoint_uri : URI = URI.parse("http://localhost:8080/")

      def initialize(endpoint, @headers, @clients)
        @endpoint_uri = uninitialized URI
        @clients = uninitialized DB::Pool(HTTP::Client)
        initialize_client_pool
      end

      def initialize(&blk : Http ->)
        @endpoint_uri = uninitialized URI
        @clients = uninitialized DB::Pool(HTTP::Client)
        yield self
        initialize_client_pool
      end

      def initialize_client_pool
        return if @clients
        @clients = DB::Pool(HTTP::Client).new do
          client = HTTP::Client.new(@endpoint_uri)

          client.before_request do |request|
            # Ensure that the minimum necessary headers are set.
            setup_standard_headers(request.headers)

            # Populate the request headers with any other desired headers.
            @headers.each do |key, value|
              request.headers[key] = value
            end
          end
          client
        end
      end

      # For other HTTP based protocols, such as gRPC, this method should be
      # overridden to set the appropriate protocol specific headers.
      def setup_standard_headers(headers)
        headers["content-type"] = "application/x-protobuf"
        headers["connection"] = "keep-alive"
      end

      def endpoint
        @endpoint_uri
      end

      def endpoint=(uri : Uri)
        @endpoint_uri = uri
        @endpoint_uri.path = "/" if @endpoint_uri.path.empty?
      end

      def endpoint=(uri : String)
        @endpoint_uri = URI.parse(uri)
        @endpoint_uri.path = "/" if @endpoint_uri.path.empty?
      end

      def handle(elements : Array(Elements))
        batches = collate(elements)
        @clients.checkout do |client|
          if !batches[:traces].empty?
            # TODO: handle errors; retry?
            response = client.post(
              @endpoint_uri.path,
              body: generate_payload(
                Proto::Collector::Trace::V1::ExportTraceServiceRequest.new(
                  resource_spans: batches[:traces]).to_protobuf
              )
            )
            {% begin %}
            {% if flag? :DEBUG %}
            pp response
            {% end %}
            {% end %}
          end
        end
      end

      def generate_payload(request)
        request.to_slice
      end

      def collate(elements)
        # TODO: Expand this to support metrics and logs, too.
        batches = {
          traces: [] of Proto::Trace::V1::ResourceSpans,
        }
        elements.each do |element|
          case element
          when Trace
            batches[:traces] << element.to_protobuf
          end
        end

        batches
      end
    end
  end
end

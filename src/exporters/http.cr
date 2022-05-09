require "db/pool"
require "retriable"
require "http/client"
require "./buffered_base"

module HTTP
  private def self.check_content_type_charset(body, headers)
    return unless body

    content_type = headers["Content-Type"]?
    return unless content_type

    mime_type = MIME::MediaType.parse?(content_type.split(",")[0])
    return unless mime_type

    charset = mime_type["charset"]?
    return if !charset || charset == "utf-8"

    body.set_encoding(charset, invalid: :skip)
  end
end

module OpenTelemetry
  class Exporter
    class Http < BufferedBase
      property clients : DB::Pool(HTTP::Client)
      @clients_are_initialized : Bool = false
      property headers : HTTP::Headers = HTTP::Headers.new
      property endpoint_uri : URI = URI.parse("http://localhost:8080/")

      def initialize(endpoint : String? = nil, _headers : HTTP::Headers? = nil, _clients : DB::Pool(HTTP::Client)? = nil, *_junk, **_kwjunk)
        @endpoint_uri = endpoint if endpoint
        @headers = _headers if _headers
        if _clients
          @clients = _clients
          @clients_are_initialized = true
        else
          @clients = uninitialized DB::Pool(HTTP::Client)
        end
        initialize_client_pool
        start
      end

      def initialize
        @clients_are_initialized = false
        @clients = uninitialized DB::Pool(HTTP::Client)
        yield self
        initialize_client_pool
        start
      end

      def initialize_client_pool
        return if @clients_are_initialized
        @clients = DB::Pool(HTTP::Client).new do
          client = HTTP::Client.new(@endpoint_uri)

          client.before_request do |request|
            # Ensure that the minimum necessary headers are set.
            setup_standard_headers(request.headers)

            # Set span to be non-recording. # TODO: Should this also be wrapped in a conditional
            # macro, so that this code doesn't even exist unless the ENV variable is set when the
            # code is compiled?
            if ENV["OTEL_CRYSTAL_ENABLE_INSTRUMENTATION_SELF"]? && (span = OpenTelemetry.current_span)
              span.is_recording = false
            end
          end
          client
        end
        @clients_are_initialized = true
      end

      # For other HTTP based protocols, such as gRPC, this method should be
      # overridden to set the appropriate protocol specific headers.
      def setup_standard_headers(headers)
        headers["Content-Type"] = "application/x-protobuf"
        headers["Connection"] = "keep-alive"
        @headers.each do |key, value|
          headers[key] = value
        end

        headers
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
        unless batches[:traces].empty?
          begin
            body = generate_payload(
              Proto::Collector::Trace::V1::ExportTraceServiceRequest.new(
                resource_spans: batches[:traces]).to_protobuf)
          rescue ex : Exception
            puts "Failed to generate payload: #{ex}"
            return
          end

          begin
            Retriable.retry(max_attempts: 5) do
              @clients.checkout do |client|
                response = client.post(
                  @endpoint_uri.path,
                  body: body
                )
                {% begin %}
              {% if flag? :DEBUG %}
              pp response
              {% end %}
              {% end %}
              end
            end
          rescue ex
            puts "Failed to send payload: #{ex}"
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
            pb_or_nil = element.to_protobuf
            batches[:traces] << pb_or_nil if pb_or_nil
          end
        end

        batches
      end

      def user_agent
        "OpenTelemetry/Crystal #{VERSION}"
      end
    end
  end
end

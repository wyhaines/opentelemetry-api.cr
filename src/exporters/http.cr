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
      property endpoint_uri : URI = normalized_traces_endpoint_uri(
        ENV["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"]? ||
        ENV["OTEL_EXPORTER_OTLP_ENDPOINT"]? ||
        "http://localhost:4318")

      def initialize(endpoint : String? | URI = nil, _headers : HTTP::Headers? = nil, _clients : DB::Pool(HTTP::Client)? = nil, *_junk, **_kwjunk)
        @endpoint_uri = self.class.normalized_traces_endpoint_uri(endpoint) if endpoint
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
          end
          client
        end
        @clients_are_initialized = true
      end

      # TODO: Once we support more than just traces, how this all works will have to be revised.
      def self.normalized_traces_endpoint_uri(endpoint_uri : String)
        parsed_endpoint_uri = URI.parse(endpoint_uri)
        parsed_endpoint_uri.path.ends_with?("traces") ? parsed_endpoint_uri : URI.parse(
          Path.new(endpoint_uri)
            .join("/v1/traces")
            .to_s)
      end

      def self.normalized_traces_endpoint_uri(endpoint_uri : URI)
        endpoint_uri.path.ends_with?("traces") ? endpoint_uri : URI.parse(
          Path.new(endpoint_uri.to_s)
            .join("/v1/traces")
            .to_s)
      end

      # For other HTTP based protocols, such as gRPC, this method should be
      # overridden to set the appropriate protocol specific headers.
      def setup_standard_headers(headers)
        headers["Content-Type"] = "application/x-protobuf"
        headers["Connection"] = "keep-alive"
        add_env_based_headers(headers)

        @headers.each do |key, value|
          headers[key] = value
        end

        headers
      end

      private def add_env_based_headers(headers)
        # TODO: This behavior is not spec-conformant, and will be broken as soon
        # as more than just Traces are implemented, so clean this up and make it
        # right sooner rather than later.
        extra_headers = [] of String
        if chunk = ENV["OTEL_EXPORTER_OTLP_HEADERS"]?
          extra_headers.concat chunk.split(/\s*,\s*/)
        end

        if chunk = ENV["OTEL_EXPORTER_OTLP_TRACES_HEADERS"]?
          extra_headers.concat chunk.split(/\s*,\s*/)
        end

        extra_headers.each do |header|
          key, value = header.split(/\s*=\s*/, 2)
          headers[key] = value
        end

        headers
      end

      def endpoint
        @endpoint_uri
      end

      def endpoint=(uri : URI)
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
                OpenTelemetry.trace.in_span("Send OTLP/HTTP to Ingest") do |span|
                  # By default, spans wrapping the internal operation of the exporter
                  # should not be recorded.
                  if !ENV["OTEL_CRYSTAL_ENABLE_INSTRUMENTATION_SELF"]?
                    span.is_recording = false
                  else
                    span.is_recording = true
                  end

                  response = client.post(
                    @endpoint_uri.path,
                    body: body
                  )
                  debug!(response)
                end
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

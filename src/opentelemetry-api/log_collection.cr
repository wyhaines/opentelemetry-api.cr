require "./sendable"

module OpenTelemetry
  class LogColletion
    include Sendable

    property logs : Array(Log) = [] of Log
    @exported : Bool = false

    # TODO: Add support for Resources
    # A LogCollection will typically be managed by a LogProvider. This class
    # encapsulates the logic necessary to package a set of logs into a single
    # transaction.

    def to_protobuf
      Proto::Trace::V1::ResourceLogs.new(
        instrumentation_library_logs: [
          Proto::Trace::V1::InstrumentationLibraryLogs.new(
            instrumentation_library: OpenTelemetry.instrumentation_library,
            logs: logs.map(&.to_protobuf),
            schema_url: schema_url),
        ],
        schema_url: schema_url
      )
    end

    def to_json
      String.build do |json|
        json << "{\n"
        json << "  \"type\":\"trace\",\n"
        json << "  \"traceId\":\"#{trace_id.hexstring}\",\n"
        json << "  \"spans\":[\n"
        json << String.build do |span_list|
          iterate_span_nodes(root_span) do |span|
            span_list << "    "
            span_list << span.to_json if span
            span_list << ",\n"
          end
        end.chomp(",\n")
        json << "\n  ]\n"
        json << "}"
      end
    end
  end
end

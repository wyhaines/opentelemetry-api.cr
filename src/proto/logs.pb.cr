# # Generated from opentelemetry/proto/logs/v1/logs.proto for opentelemetry.proto.logs.v1
require "protobuf"

require "./common.pb.cr"
require "./resource.pb.cr"

module OpenTelemetry
  module Proto
    module Logs
      module V1
        enum SeverityNumber
          SEVERITYNUMBERUNSPECIFIED =  0
          SEVERITYNUMBERTRACE       =  1
          SEVERITYNUMBERTRACE2      =  2
          SEVERITYNUMBERTRACE3      =  3
          SEVERITYNUMBERTRACE4      =  4
          SEVERITYNUMBERDEBUG       =  5
          SEVERITYNUMBERDEBUG2      =  6
          SEVERITYNUMBERDEBUG3      =  7
          SEVERITYNUMBERDEBUG4      =  8
          SEVERITYNUMBERINFO        =  9
          SEVERITYNUMBERINFO2       = 10
          SEVERITYNUMBERINFO3       = 11
          SEVERITYNUMBERINFO4       = 12
          SEVERITYNUMBERWARN        = 13
          SEVERITYNUMBERWARN2       = 14
          SEVERITYNUMBERWARN3       = 15
          SEVERITYNUMBERWARN4       = 16
          SEVERITYNUMBERERROR       = 17
          SEVERITYNUMBERERROR2      = 18
          SEVERITYNUMBERERROR3      = 19
          SEVERITYNUMBERERROR4      = 20
          SEVERITYNUMBERFATAL       = 21
          SEVERITYNUMBERFATAL2      = 22
          SEVERITYNUMBERFATAL3      = 23
          SEVERITYNUMBERFATAL4      = 24
        end
        enum LogRecordFlags
          LOGRECORDFLAGUNSPECIFIED    =   0
          LOGRECORDFLAGTRACEFLAGSMASK = 255
        end

        struct LogsData
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :resource_logs, ResourceLogs, 1
          end
        end

        struct ResourceLogs
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :resource, OpenTelemetry::Proto::Resource::V1::Resource, 1
            repeated :scope_logs, ScopeLogs, 2
            repeated :instrumentation_library_logs, InstrumentationLibraryLogs, 1000
            optional :schema_url, :string, 3
          end
        end

        struct ScopeLogs
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :scope, OpenTelemetry::Proto::Common::V1::InstrumentationScope, 1
            repeated :log_records, LogRecord, 2
            optional :schema_url, :string, 3
          end
        end

        struct InstrumentationLibraryLogs
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :instrumentation_library, OpenTelemetry::Proto::Common::V1::InstrumentationLibrary, 1
            repeated :log_records, LogRecord, 2
            optional :schema_url, :string, 3
          end
        end

        struct LogRecord
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :time_unix_nano, :fixed64, 1
            optional :observed_time_unix_nano, :fixed64, 11
            optional :severity_number, SeverityNumber, 2
            optional :severity_text, :string, 3
            optional :body, OpenTelemetry::Proto::Common::V1::AnyValue, 5
            repeated :attributes, OpenTelemetry::Proto::Common::V1::KeyValue, 6
            optional :dropped_attributes_count, :uint32, 7
            optional :flags, :fixed32, 8
            optional :trace_id, :bytes, 9
            optional :span_id, :bytes, 10
          end
        end
      end
    end
  end
end

# # Generated from opentelemetry/proto/collector/logs/v1/logs_service.proto for opentelemetry.proto.collector.logs.v1
require "protobuf"

require "./logs.pb.cr"

module OpenTelemetry
  module Proto
    module Collector
      module Logs
        module V1
          struct ExportLogsServiceRequest
            include ::Protobuf::Message

            contract_of "proto3" do
              repeated :resource_logs, OpenTelemetry::Proto::Logs::V1::ResourceLogs, 1
            end
          end

          struct ExportLogsServiceResponse
            include ::Protobuf::Message

            contract_of "proto3" do
            end
          end
        end
      end
    end
  end
end

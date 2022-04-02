# # Generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto for opentelemetry.proto.collector.metrics.v1
require "protobuf"

require "./metrics.pb.cr"

module OpenTelemetry
  module Proto
    module Collector
      module Metrics
        module V1
          struct ExportMetricsServiceRequest
            include ::Protobuf::Message

            contract_of "proto3" do
              repeated :resource_metrics, OpenTelemetry::Proto::Metrics::V1::ResourceMetrics, 1
            end
          end

          struct ExportMetricsServiceResponse
            include ::Protobuf::Message

            contract_of "proto3" do
            end
          end
        end
      end
    end
  end
end

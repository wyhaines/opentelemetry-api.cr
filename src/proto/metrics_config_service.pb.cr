# # Generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto for opentelemetry.proto.metrics.experimental
require "protobuf"

require "./resource.pb.cr"

module OpenTelemetry
  module Proto
    module Metrics
      module Experimental
        struct MetricConfigRequest
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :resource, OpenTelemetry::Proto::Resource::V1::Resource, 1
            optional :last_known_fingerprint, :bytes, 2
          end
        end

        struct MetricConfigResponse
          include ::Protobuf::Message

          struct Schedule
            include ::Protobuf::Message

            struct Pattern
              include ::Protobuf::Message

              contract_of "proto3" do
                optional :equals, :string, 1
                optional :starts_with, :string, 2
              end
            end

            contract_of "proto3" do
              repeated :exclusion_patterns, MetricConfigResponse::Schedule::Pattern, 1
              repeated :inclusion_patterns, MetricConfigResponse::Schedule::Pattern, 2
              optional :period_sec, :int32, 3
            end
          end

          contract_of "proto3" do
            optional :fingerprint, :bytes, 1
            repeated :schedules, MetricConfigResponse::Schedule, 2
            optional :suggested_wait_time_sec, :int32, 3
          end
        end
      end
    end
  end
end

# # Generated from opentelemetry/proto/trace/v1/trace_config.proto for opentelemetry.proto.trace.v1
require "protobuf"

module OpenTelemetry
  module Proto
    module Trace
      module V1
        struct TraceConfig
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :constant_sampler, ConstantSampler, 1
            optional :trace_id_ratio_based, TraceIdRatioBased, 2
            optional :rate_limiting_sampler, RateLimitingSampler, 3
            optional :max_number_of_attributes, :int64, 4
            optional :max_number_of_timed_events, :int64, 5
            optional :max_number_of_attributes_per_timed_event, :int64, 6
            optional :max_number_of_links, :int64, 7
            optional :max_number_of_attributes_per_link, :int64, 8
          end
        end

        struct ConstantSampler
          include ::Protobuf::Message
          enum ConstantDecision
            ALWAYSOFF    = 0
            ALWAYSON     = 1
            ALWAYSPARENT = 2
          end

          contract_of "proto3" do
            optional :decision, ConstantSampler::ConstantDecision, 1
          end
        end

        struct TraceIdRatioBased
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :sampling_ratio, :double, 1
          end
        end

        struct RateLimitingSampler
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :qps, :int64, 1
          end
        end
      end
    end
  end
end

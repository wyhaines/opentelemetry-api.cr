# # Generated from opentelemetry/proto/metrics/v1/metrics.proto for opentelemetry.proto.metrics.v1
require "protobuf"

require "./common.pb.cr"
require "./resource.pb.cr"

module OpenTelemetry
  module Proto
    module Metrics
      module V1
        enum AggregationTemporality
          AGGREGATIONTEMPORALITYUNSPECIFIED = 0
          AGGREGATIONTEMPORALITYDELTA       = 1
          AGGREGATIONTEMPORALITYCUMULATIVE  = 2
        end
        enum DataPointFlags
          FLAGNONE            = 0
          FLAGNORECORDEDVALUE = 1
        end

        struct ResourceMetrics
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :resource, OpenTelemetry::Proto::Resource::V1::Resource, 1
            repeated :instrumentation_library_metrics, InstrumentationLibraryMetrics, 2
            optional :schema_url, :string, 3
          end
        end

        struct InstrumentationLibraryMetrics
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :instrumentation_library, OpenTelemetry::Proto::Common::V1::InstrumentationLibrary, 1
            repeated :metrics, Metric, 2
            optional :schema_url, :string, 3
          end
        end

        struct Metric
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :name, :string, 1
            optional :description, :string, 2
            optional :unit, :string, 3
            optional :int_gauge, IntGauge, 4
            optional :gauge, Gauge, 5
            optional :int_sum, IntSum, 6
            optional :sum, Sum, 7
            optional :int_histogram, IntHistogram, 8
            optional :histogram, Histogram, 9
            optional :exponential_histogram, ExponentialHistogram, 10
            optional :summary, Summary, 11
          end
        end

        struct Gauge
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :data_points, NumberDataPoint, 1
          end
        end

        struct Sum
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :data_points, NumberDataPoint, 1
            optional :aggregation_temporality, AggregationTemporality, 2
            optional :is_monotonic, :bool, 3
          end
        end

        struct Histogram
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :data_points, HistogramDataPoint, 1
            optional :aggregation_temporality, AggregationTemporality, 2
          end
        end

        struct ExponentialHistogram
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :data_points, ExponentialHistogramDataPoint, 1
            optional :aggregation_temporality, AggregationTemporality, 2
          end
        end

        struct Summary
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :data_points, SummaryDataPoint, 1
          end
        end

        struct NumberDataPoint
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :attributes, OpenTelemetry::Proto::Common::V1::KeyValue, 7
            repeated :labels, OpenTelemetry::Proto::Common::V1::StringKeyValue, 1
            optional :start_time_unix_nano, :fixed64, 2
            optional :time_unix_nano, :fixed64, 3
            optional :as_double, :double, 4
            optional :as_int, :sfixed64, 6
            repeated :exemplars, Exemplar, 5
            optional :flags, :uint32, 8
          end
        end

        struct HistogramDataPoint
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :attributes, OpenTelemetry::Proto::Common::V1::KeyValue, 9
            repeated :labels, OpenTelemetry::Proto::Common::V1::StringKeyValue, 1
            optional :start_time_unix_nano, :fixed64, 2
            optional :time_unix_nano, :fixed64, 3
            optional :count, :fixed64, 4
            optional :sum, :double, 5
            repeated :bucket_counts, :fixed64, 6
            repeated :explicit_bounds, :double, 7
            repeated :exemplars, Exemplar, 8
            optional :flags, :uint32, 10
          end
        end

        struct ExponentialHistogramDataPoint
          include ::Protobuf::Message

          struct Buckets
            include ::Protobuf::Message

            contract_of "proto3" do
              optional :offset, :sint32, 1
              repeated :bucket_counts, :uint64, 2
            end
          end

          contract_of "proto3" do
            repeated :attributes, OpenTelemetry::Proto::Common::V1::KeyValue, 1
            optional :start_time_unix_nano, :fixed64, 2
            optional :time_unix_nano, :fixed64, 3
            optional :count, :fixed64, 4
            optional :sum, :double, 5
            optional :scale, :sint32, 6
            optional :zero_count, :fixed64, 7
            optional :positive, ExponentialHistogramDataPoint::Buckets, 8
            optional :negative, ExponentialHistogramDataPoint::Buckets, 9
            optional :flags, :uint32, 10
            repeated :exemplars, Exemplar, 11
          end
        end

        struct SummaryDataPoint
          include ::Protobuf::Message

          struct ValueAtQuantile
            include ::Protobuf::Message

            contract_of "proto3" do
              optional :quantile, :double, 1
              optional :value, :double, 2
            end
          end

          contract_of "proto3" do
            repeated :attributes, OpenTelemetry::Proto::Common::V1::KeyValue, 7
            repeated :labels, OpenTelemetry::Proto::Common::V1::StringKeyValue, 1
            optional :start_time_unix_nano, :fixed64, 2
            optional :time_unix_nano, :fixed64, 3
            optional :count, :fixed64, 4
            optional :sum, :double, 5
            repeated :quantile_values, SummaryDataPoint::ValueAtQuantile, 6
            optional :flags, :uint32, 8
          end
        end

        struct Exemplar
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :filtered_attributes, OpenTelemetry::Proto::Common::V1::KeyValue, 7
            repeated :filtered_labels, OpenTelemetry::Proto::Common::V1::StringKeyValue, 1
            optional :time_unix_nano, :fixed64, 2
            optional :as_double, :double, 3
            optional :as_int, :sfixed64, 6
            optional :span_id, :bytes, 4
            optional :trace_id, :bytes, 5
          end
        end

        struct IntDataPoint
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :labels, OpenTelemetry::Proto::Common::V1::StringKeyValue, 1
            optional :start_time_unix_nano, :fixed64, 2
            optional :time_unix_nano, :fixed64, 3
            optional :value, :sfixed64, 4
            repeated :exemplars, IntExemplar, 5
          end
        end

        struct IntGauge
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :data_points, IntDataPoint, 1
          end
        end

        struct IntSum
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :data_points, IntDataPoint, 1
            optional :aggregation_temporality, AggregationTemporality, 2
            optional :is_monotonic, :bool, 3
          end
        end

        struct IntHistogramDataPoint
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :labels, OpenTelemetry::Proto::Common::V1::StringKeyValue, 1
            optional :start_time_unix_nano, :fixed64, 2
            optional :time_unix_nano, :fixed64, 3
            optional :count, :fixed64, 4
            optional :sum, :sfixed64, 5
            repeated :bucket_counts, :fixed64, 6
            repeated :explicit_bounds, :double, 7
            repeated :exemplars, IntExemplar, 8
          end
        end

        struct IntHistogram
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :data_points, IntHistogramDataPoint, 1
            optional :aggregation_temporality, AggregationTemporality, 2
          end
        end

        struct IntExemplar
          include ::Protobuf::Message

          contract_of "proto3" do
            repeated :filtered_labels, OpenTelemetry::Proto::Common::V1::StringKeyValue, 1
            optional :time_unix_nano, :fixed64, 2
            optional :value, :sfixed64, 3
            optional :span_id, :bytes, 4
            optional :trace_id, :bytes, 5
          end
        end
      end
    end
  end
end

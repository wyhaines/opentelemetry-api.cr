# # Generated from opentelemetry/proto/trace/v1/trace.proto for opentelemetry.proto.trace.v1
require "protobuf"

require "./common.pb.cr"
require "./resource.pb.cr"

module OpenTelemetry
  module Proto
    module Trace
      module V1
        struct ResourceSpans
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :resource, OpenTelemetry::Proto::Resource::V1::Resource, 1
            repeated :instrumentation_library_spans, InstrumentationLibrarySpans, 2
            optional :schema_url, :string, 3
          end
        end

        struct InstrumentationLibrarySpans
          include ::Protobuf::Message

          contract_of "proto3" do
            optional :instrumentation_library, OpenTelemetry::Proto::Common::V1::InstrumentationLibrary, 1
            repeated :spans, Span, 2
            optional :schema_url, :string, 3
          end
        end

        struct Span
          include ::Protobuf::Message
          enum SpanKind
            SPANKINDUNSPECIFIED = 0
            SPANKINDINTERNAL    = 1
            SPANKINDSERVER      = 2
            SPANKINDCLIENT      = 3
            SPANKINDPRODUCER    = 4
            SPANKINDCONSUMER    = 5
          end

          struct Event
            include ::Protobuf::Message

            contract_of "proto3" do
              optional :time_unix_nano, :fixed64, 1
              optional :name, :string, 2
              repeated :attributes, OpenTelemetry::Proto::Common::V1::KeyValue, 3
              optional :dropped_attributes_count, :uint32, 4
            end
          end

          struct Link
            include ::Protobuf::Message

            contract_of "proto3" do
              optional :trace_id, :bytes, 1
              optional :span_id, :bytes, 2
              optional :trace_state, :string, 3
              repeated :attributes, OpenTelemetry::Proto::Common::V1::KeyValue, 4
              optional :dropped_attributes_count, :uint32, 5
            end
          end

          contract_of "proto3" do
            optional :trace_id, :bytes, 1
            optional :span_id, :bytes, 2
            optional :trace_state, :string, 3
            optional :parent_span_id, :bytes, 4
            optional :name, :string, 5
            optional :kind, Span::SpanKind, 6
            optional :start_time_unix_nano, :fixed64, 7
            optional :end_time_unix_nano, :fixed64, 8
            repeated :attributes, OpenTelemetry::Proto::Common::V1::KeyValue, 9
            optional :dropped_attributes_count, :uint32, 10
            repeated :events, Span::Event, 11
            optional :dropped_events_count, :uint32, 12
            repeated :links, Span::Link, 13
            optional :dropped_links_count, :uint32, 14
            optional :status, Status, 15
          end
        end

        struct Status
          include ::Protobuf::Message
          enum DeprecatedStatusCode
            DEPRECATEDSTATUSCODEOK                 =  0
            DEPRECATEDSTATUSCODECANCELLED          =  1
            DEPRECATEDSTATUSCODEUNKNOWNERROR       =  2
            DEPRECATEDSTATUSCODEINVALIDARGUMENT    =  3
            DEPRECATEDSTATUSCODEDEADLINEEXCEEDED   =  4
            DEPRECATEDSTATUSCODENOTFOUND           =  5
            DEPRECATEDSTATUSCODEALREADYEXISTS      =  6
            DEPRECATEDSTATUSCODEPERMISSIONDENIED   =  7
            DEPRECATEDSTATUSCODERESOURCEEXHAUSTED  =  8
            DEPRECATEDSTATUSCODEFAILEDPRECONDITION =  9
            DEPRECATEDSTATUSCODEABORTED            = 10
            DEPRECATEDSTATUSCODEOUTOFRANGE         = 11
            DEPRECATEDSTATUSCODEUNIMPLEMENTED      = 12
            DEPRECATEDSTATUSCODEINTERNALERROR      = 13
            DEPRECATEDSTATUSCODEUNAVAILABLE        = 14
            DEPRECATEDSTATUSCODEDATALOSS           = 15
            DEPRECATEDSTATUSCODEUNAUTHENTICATED    = 16
          end
          enum StatusCode
            STATUSCODEUNSET = 0
            STATUSCODEOK    = 1
            STATUSCODEERROR = 2
          end

          contract_of "proto3" do
            optional :deprecated_code, Status::DeprecatedStatusCode, 1
            optional :message, :string, 2
            optional :code, Status::StatusCode, 3
          end
        end
      end
    end
  end
end

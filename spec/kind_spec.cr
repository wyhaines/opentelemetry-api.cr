require "./spec_helper"

describe OpenTelemetry::Span::Kind do
  it "defines the expected span kinds" do
    kinds_from_protobuf = {
      SPANKINDUNSPECIFIED: 0,
      SPANKINDINTERNAL:    1,
      SPANKINDSERVER:      2,
      SPANKINDCLIENT:      3,
      SPANKINDPRODUCER:    4,
      SPANKINDCONSUMER:    5,
    }

    OpenTelemetry::Span::Kind::Unspecified.value.should eq kinds_from_protobuf[:SPANKINDUNSPECIFIED]
    OpenTelemetry::Span::Kind::Internal.value.should eq kinds_from_protobuf[:SPANKINDINTERNAL]
    OpenTelemetry::Span::Kind::Server.value.should eq kinds_from_protobuf[:SPANKINDSERVER]
    OpenTelemetry::Span::Kind::Client.value.should eq kinds_from_protobuf[:SPANKINDCLIENT]
    OpenTelemetry::Span::Kind::Producer.value.should eq kinds_from_protobuf[:SPANKINDPRODUCER]
    OpenTelemetry::Span::Kind::Consumer.value.should eq kinds_from_protobuf[:SPANKINDCONSUMER]
  end
end

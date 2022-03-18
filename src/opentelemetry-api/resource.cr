require "../proto/resource.pb"
require "./sendable"

module OpenTelemetry
  class Resource
    include Sendable

    property attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
    property dropped_attribute_count : UInt32 = 0

    @exported : Bool = false

    def initialize(attrs)
      attrs.each { |key, value| self[key] = value }
    end

    def initialize
    end

    def []=(key, value)
      attributes[key] = AnyAttribute.new(key: key, value: value)
    end

    def set_attribute(key, value)
      self[key] = value
    end

    def [](key)
      attributes[key].value
    end

    def get_attribute(key)
      attributes[key]
    end

    # The ProtoBuf differs a LOT from the current Spec. Methinks this has changed a bunch since I last updated it.
    def to_protobuf
      resource = Proto::Resource::V1::Resource.new
      resource.attributes = attributes.map do |key, value|
        Proto::Common::V1::KeyValue.new(
          key: key,
          value: Attribute.to_anyvalue(value))
      end

      resource
    end

    def to_json
      String.build do |json|
        json << "{\n"
        json << "  \"resource\":{\n"
        attributes.each do |_, value|
          json << "    #{value.to_json},\n"
        end
        json << "  },\n"
        json << "}\n"
      end
    end
  end
end

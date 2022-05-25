require "../proto/resource.pb"
require "./sendable"

module OpenTelemetry
  class Resource
    include Sendable

    property attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
    property dropped_attribute_count : UInt32 = 0

    @exported : Bool = false

    # Create a new Resource that has been intialized by the provided key/value pairs.
    # This initialization will support any seed object that provides an `#each` method
    # which takes a two-argument block.
    def initialize(attrs)
      attrs.each { |key, value| self[key] = value }
    end

    # Create an empty Resource.
    def initialize
    end

    # Assign a value to a key in the Resource.
    def []=(key, value)
      attributes[key] = AnyAttribute.new(key: key, value: value)
    end

    # Alias for `#[]=`
    def set_attribute(key, value)
      self[key] = value
    end

    # Retrieve the value for a key in the Resource.
    def [](key)
      attributes[key].value
    end

    # Alias for `#[]`
    def get_attribute(key)
      attributes[key]
    end

    # Retrieve a value for a key in the Resource. Return nil instead of an exception if the key is not present.
    def []?(key)
      attributes[key]?
    end

    # Alias for `#[]?`
    def get_attribute?(key)
      attributes[key]?
    end

    # Return true if the resource is empty.
    def empty?
      attributes.empty?
    end

    # Export the resource to its protocol buffer representation.
    def to_protobuf
      resource = Proto::Resource::V1::Resource.new
      resource.attributes = attributes.map do |key, value|
        Proto::Common::V1::KeyValue.new(
          key: key,
          value: Attribute.to_anyvalue(value))
      end

      resource
    end

    # Export the resource with a JSON representation.
    def to_json
      String.build do |json|
        json << "{\n"
        json << "  \"resource\":{\n"
        json << attribute_list
        json << "  }\n"
        json << "}\n"
      end
    end

    def attribute_list(indent = 4)
      spacer = " " * indent
      String.build do |attribute_list|
        attributes.each do |_, value|
          attribute_list << "#{spacer}#{value.to_json},\n"
        end
      end.chomp(",\n")
    end
  end
end

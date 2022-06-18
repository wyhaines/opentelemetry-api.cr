require "./sendable"

module OpenTelemetry
  module API
    abstract class AbstractResource
      include Sendable

      abstract def attributes
      abstract def attributes=(val : Hash(String, AnyAttribute))

      abstract def dropped_attribute_count
      abstract def dropped_attribute_count=(val : UInt32)

      @exported : Bool = false

      # Create a new Resource that has been intialized by the provided key/value pairs.
      # This initialization will support any seed object that provides an `#each` method
      # which takes a two-argument block.
      abstract def initialize(attrs)

      # Create an empty Resource.
      abstract def initialize

      # Assign a value to a key in the Resource.
      abstract def []=(key, value)

      # Alias for `#[]=`
      abstract def set_attribute(key, value)

      # Retrieve the value for a key in the Resource.
      abstract def [](key)

      # Alias for `#[]`
      abstract def get_attribute(key)

      # Retrieve a value for a key in the Resource. Return nil instead of an exception if the key is not present.
      abstract def []?(key)

      # Alias for `#[]?`
      abstract def get_attribute?(key)

      # Return true if the resource is empty.
      abstract def empty?

      # Export the resource to its protocol buffer representation.
      abstract def to_protobuf

      # Export the resource with a JSON representation.
      abstract def to_json

      abstract def to_json(json : JSON::Builder)
    end
  end
end

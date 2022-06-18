require "./sendable"

module OpenTelemetry
  module API
    class Resource < AbstractResource
      property attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
      property dropped_attribute_count : UInt32 = 0

      # Create a new Resource that has been intialized by the provided key/value pairs.
      # This initialization will support any seed object that provides an `#each` method
      # which takes a two-argument block.
      def initialize(attrs)
      end

      # Create an empty Resource.
      def initialize
      end

      # Assign a value to a key in the Resource.
      def []=(key, value)
      end

      # Alias for `#[]=`
      def set_attribute(key, value)
      end

      # Retrieve the value for a key in the Resource.
      def [](key)
      end

      # Alias for `#[]`
      def get_attribute(key)
      end

      # Retrieve a value for a key in the Resource. Return nil instead of an exception if the key is not present.
      def []?(key)
      end

      # Alias for `#[]?`
      def get_attribute?(key)
      end

      # Return true if the resource is empty.
      def empty?
      end

      # Export the resource to its protocol buffer representation.
      def to_protobuf
      end

      # Export the resource with a JSON representation.
      def to_json
      end

      def to_json(json : JSON::Builder)
      end
    end
  end
end

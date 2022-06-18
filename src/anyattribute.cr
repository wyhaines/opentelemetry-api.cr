require "./attribute"

module OpenTelemetry
  # This is a wrapper around the supported attribute types.
  class AnyAttribute
    alias Type = Attribute(String) |
                 Attribute(Bool) |
                 Attribute(Float64) |
                 Attribute(Int64) |
                 Attribute(Int32) |
                 Attribute(Array(String)) |
                 Attribute(Array(Bool)) |
                 Attribute(Array(Float64)) |
                 Attribute(Array(Int64)) |
                 Attribute(Array(Int32))

    getter raw : Type

    def initialize(raw : Attribute)
      @raw = raw
    end

    # ameba:disable Metrics/CyclomaticComplexity
    def initialize(key : String, value : ValueTypes | UInt64)
      case value
      when String
        @raw = Attribute(String).new(key, value)
      when Bool
        @raw = Attribute(Bool).new(key, value)
      when Float64
        @raw = Attribute(Float64).new(key, value)
      when Int64, UInt64
        @raw = Attribute(Int64).new(key, value.to_i64)
      when Int32
        @raw = Attribute(Int32).new(key, value)
      when Array(String)
        @raw = Attribute(Array(String)).new(key, value)
      when Array(Bool)
        @raw = Attribute(Array(Bool)).new(key, value)
      when Array(Float64)
        @raw = Attribute(Array(Float64)).new(key, value)
      when Array(Int64)
        @raw = Attribute(Array(Int64)).new(key, value)
      when Array(Int32)
        @raw = Attribute(Array(Int32)).new(key, value)
      else
        raise ArgumentError.new("#{value} is not a valid type")
      end
    end

    # ameba:disable Metrics/CyclomaticComplexity
    def <<(value : ValueType | ValueArrays)
      case object = @raw
      when Attribute(String)
        @raw = Attribute(Array(String)).new(object.key, [object.value.as(String)])
      when Attribute(Bool)
        @raw = Attribute(Array(Bool)).new(object.key, [object.value.as(Bool)])
      when Attribute(Float64)
        @raw = Attribute(Array(Float64)).new(@raw.key, [@raw.value.as(Float64)])
      when Attribute(Int64)
        @raw = Attribute(Array(Int64)).new(@raw.key, [@raw.value.as(Int64)])
      when Attribute(Int32)
        @raw = Attribute(Array(Int32)).new(@raw.key, [@raw.value.as(Int32)])
      end

      case value
      when String
        @raw.value.as(Array(String)) << value
      when Bool
        @raw.value.as(Array(Bool)) << value
      when Float64
        @raw.value.as(Array(Float64)) << value
      when Int64
        @raw.value.as(Array(Int64)) << value
      when Int32
        @raw.value.as(Array(Int32)) << value
      when Array(String)
        @raw.value.as(Array(String)).concat value
      when Array(Bool)
        @raw.value.as(Array(Bool)).concat value
      when Array(Float64)
        @raw.value.as(Array(Float64)).concat value
      when Array(Int64)
        @raw.value.as(Array(Int64)).concat value
      when Array(Int32)
        @raw.value.as(Array(Int32)).concat value
      else
        raise ArgumentError.new("#{value} is not a valid type")
      end
    end

    def value
      @raw.value
    end

    def key
      @raw.key
    end

    def [](index)
      case object = @raw.value
      when Array, String
        object[index]
      else
        raise "Expected Attribute(Array) or Attribute(String) for #[](index : Int), not #{object.class}"
      end
    end

    def []?(index)
      case object = @raw.value
      when Array, String
        object[index]?
      else
        raise "Expected Attribute(Array) or Attribute(String) for #[](index : Int), not #{object.class}"
      end
    end

    def []=(index, value)
      case value
      when String
        @raw.value.as(Array(String))[index] = value.as(String)
      when Bool
        @raw.value.as(Array(Bool))[index] = value.as(Bool)
      when Float64
        @raw.value.as(Array(Float64))[index] = value.as(Float64)
      when Int64
        @raw.value.as(Array(Int64))[index] = value.as(Int64)
      when Int32
        @raw.value.as(Array(Int32))[index] = value.as(Int32)
      else
        raise "Expected Attribute(Array) for #[]=(index : Int, value : ValueType), not #{@raw.value.class}"
      end
    end

    def to_json
      "\"#{key}\":#{value.to_json}"
    end

    def to_json(json : JSON::Builder)
      json.field key, value.to_json(json)
    end
  end
end

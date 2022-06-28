require "./anyvalue"

module OpenTelemetry
  alias ValueType = String | Bool | Float64 | Int64 | Int32
  alias ValueArrays = Array(String) | Array(Bool) | Array(Float64) | Array(Int64) | Array(Int32)
  alias ValueTypes = ValueType | ValueArrays

  struct Attribute(K)
    getter key : String
    getter value : K

    def self.to_anyvalue(attribute)
      case val = attribute.value
      when String
        Proto::Common::V1::AnyValue.new(string_value: val)
      when Bool
        Proto::Common::V1::AnyValue.new(bool_value: val)
      when Int
        Proto::Common::V1::AnyValue.new(int_value: val.to_i64)
      when Float
        Proto::Common::V1::AnyValue.new(double_value: val.to_f64)
      when Time
        Proto::Common::V1::AnyValue.new(string_value: val.iso8601)
      else
        Proto::Common::V1::AnyValue.new
      end
    end

    def self.from_h(hash)
      new(key: hash["key"], value: hash["value"])
    end

    def self.from_a(ary)
      new(key: ary[0], value: ary[1])
    end

    def initialize(@value)
      @key = ""
    end

    def initialize(@key, @value)
    end

    def to_h
      {key: value}
    end

    def to_s(io : IO) : Nil
      io << value
    end

    def to_i
      value.to_i64
    end

    def to_f
      value.to_f64
    end

    def to_bool
      !!value
    end
  end
end

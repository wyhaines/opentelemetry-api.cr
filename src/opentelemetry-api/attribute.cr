module OpenTelemetry
  alias ValueType = String | Bool | Float64 | Int64 | Int32
  alias ValueArrays = Array(String) | Array(Bool) | Array(Float64) | Array(Int64) | Array(Int32)
  alias ValueArray = Array(ValueType)
  record Attribute, key : String, value : ValueType | ValueArrays do
    def self.from_h(hash)
      new(key: hash["key"], value: hash["value"])
    end

    def self.from_a(ary)
      new(key: ary[0], value: ary[1])
    end

    # def to_h
    #   {key: value}
    # end

    # def to_s(io : IO) : Nil
    #   io << value
    # end

    # def to_i
    #   value.to_i64
    # end

    # def to_f
    #   value.to_f64
    # end

    # def to_bool
    #   !!value
    # end
  end
end

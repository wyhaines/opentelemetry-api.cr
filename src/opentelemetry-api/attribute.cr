module OpenTelemetry
  alias ValueArrays = Array(String) | Array(Bool) | Array(Float64) | Array(Int64)
  record Attribute, key : String, value : String | Bool | Float64 | Int64 | ValueArrays
end

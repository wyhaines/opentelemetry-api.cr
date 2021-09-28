module OpenTelemetry
  alias ValueArrays = Array(String) | Array(Boolean) | Array(Float64) | Array(Int64)
  record Attribute, key : String, value : String | Boolean | Float64 | Int64 | ValueArrays
end
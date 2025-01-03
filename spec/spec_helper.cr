require "spec"
require "json"
require "io/memory"
require "../src/anyattribute"
require "../src/opentelemetry-api"

def rand_time_span
  Time::Span.new(nanoseconds: ((rand / 1000) * 1_000_000_000).to_i64)
end

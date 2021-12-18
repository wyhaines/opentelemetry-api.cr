require "spec"
require "../src/opentelemetry-api.cr"
require "./test_exporter"

def iterate_span_nodes(span, indent, buffer)
  return if span.nil?

  buffer << "#{" " * indent}#{span.name}"
  if span && span.children
    span.children.each do |child|
      iterate_span_nodes(child, indent + 2, buffer)
    end
  end

  buffer
end

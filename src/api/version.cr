module OpenTelemetry
  {% begin %}
  VERSION = {{ read_file("#{__DIR__}/../../VERSION").chomp }}
  {% end %}
end

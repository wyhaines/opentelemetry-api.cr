module OpenTelemetry
  {% begin %}
  VERSION = {{ `git describe --tags --always`.chomp.split(/-/).first.stringify }}
  {% end %}
end

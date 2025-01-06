module OpenTelemetry
  module API
    {% begin %}
    VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
    {% end %}
  end
end

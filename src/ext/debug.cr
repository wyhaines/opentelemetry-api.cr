require "log"
require "colorize"

# This is largely copied from https://github.com/Sija/debug.cr with
# a few patches applied (mostly because I can't just monkeypatch the
# value of a constant, `ACTIVE`). The patches will be contributed back
# to the main project, and accepted, this can disappear into the void.
#
# Specifically, this version responds to both the compile time flag,
# `DEBUG`, and compile time as well as runtime flagging via the `DEBUG`
# environment variable.
#
# This version also adds a macro level debugging statement, `macro_debug!`.
module Debug
  {% begin %}
    ACTIVE = {{ flag?(:DEBUG) || (env("DEBUG") && env("DEBUG") != "0" && env("DEBUG") != "false" && env("DEBUG") != "") }}

    # This constant contains the colors used when highlighting macro
    # debugging statements via `mdebug!`. For more information on these
    # codes, see this link:
    # [https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit)
    MDEBUG_COLORS = {
      :severity => "82",
      :separator => "230",
      :file => "8",
      :lineno => "8",
      :message => "15"
    }
    class_property? enabled : Bool?

    def self.enabled? : Bool
      case enabled = @@enabled
      when Nil
        !!({{ flag?(:DEBUG) }} || (ENV["DEBUG"]? && ENV["DEBUG"] != "0" && ENV["DEBUG"] != "false" && ENV["DEBUG"].presence))
      else
        enabled
      end
    end
  {% end %}

  macro log(*args,
            severity = :debug,
            progname = nil,
            backtrace_offset = 0,
            file = __FILE__,
            line = __LINE__)

    {% unless args.empty? %}
      %arg_values = {
        {% for arg in args %}
          {{ arg }},
        {% end %}
      }

      {% if ::Debug::ACTIVE %}
        if ::Debug.enabled?
          %arg_expressions = {
            {% for arg in args %}
              {{ arg.stringify }},
            {% end %}
          }

          %settings = ::Debug.settings
          %colors = %settings.colors

          {% for arg, i in args %}
            ::Debug.logger.{{ severity.id }} do |%emitter|
              %exp, %val =
                %arg_expressions[{{ i }}], %arg_values[{{ i }}]

              %ret = String.build do |%str|
                case %settings.location_detection
                when .compile?
                  %relative_path = Path[{{ file }}].relative_to(Dir.current).to_s
                  if %relative_path
                    if %max_path_length = %settings.max_path_length
                      if %relative_path.size > %max_path_length
                        %relative_path = "…" + %relative_path[-%max_path_length..]
                      end
                    end
                    %str << "#{%relative_path}:{{ line }}"
                      .colorize(%colors[:path])
                  end

                  %def_name = {{ @def && @def.name.stringify }}
                  if %def_name
                    %str << " (#{%def_name})"
                      .colorize(%colors[:method])
                  end
                  %str << " -- "

                when .runtime?
                  %DEBUG_CALLER_PATTERN = /caller:Array\(String\)/i
                  %caller_list = caller

                  if %caller_list.any?(&.match(%DEBUG_CALLER_PATTERN))
                    while !%caller_list.empty? && %caller_list.first? !~ %DEBUG_CALLER_PATTERN
                      %caller_list.shift?
                    end
                    %caller_list.shift?
                  end

                  {% if backtrace_offset > 0 %}
                    %caller_list.shift({{ backtrace_offset }})
                  {% end %}

                  if %caller = %caller_list.first?
                    %str << %caller
                      .colorize(%colors[:method])
                    %str << " -- "
                  end
                end

                %str << '\n' if %exp['\n']?
                %str << %exp
                  .colorize(%colors[:expression])

                %str << " = "
                  .colorize(%colors[:decorator])

                %val.to_debug.tap do |%pretty_val|
                  %str << '\n' if %pretty_val['\n']?
                  %str << %pretty_val
                end
                %str << " (" << typeof(%val).to_s.colorize(%colors[:type]) << ')'
              end

              %emitter.emit(%ret, progname: {{ progname }})
            end
          {% end %}
        end
      {% end %}

      {% if args.size == 1 %}
        %arg_values.first
      {% else %}
        %arg_values
      {% end %}
    {% end %}
  end
end

# This is the main macro level debugging statement. It takes a message, and
# an optional severity level, and outputs, during macro evaluation, the
# debugging statement, highlighted according to the color codes in the
# `Debug::MDEBUG_COLORS` constant.
#
# If debugging is not active (either the `DEBUG` flag is not set, or the
# `DEBUG` environment variable is not set to a truthy value), this macro
# will do nothing.
macro macro_debug!(message,
                   severity = :debug,
                   file = __FILE__,
                   line = __LINE__)
  {% if ::Debug::ACTIVE %}
    \{%
      puts [
      "\e[38;5;{{ ::Debug::MDEBUG_COLORS[:severity].id }}m{{ severity.upcase.id }}\e[0m",
      "\e[38;5;{{ ::Debug::MDEBUG_COLORS[:separator].id }}m -- \e[0m",
      "\e[38;5;{{ ::Debug::MDEBUG_COLORS[:file].id }}m{{ file.id }}\e[0m",
      "\e[38;5;{{ ::Debug::MDEBUG_COLORS[:separator].id }}m:\e[0m",
      "\e[38;5;{{ ::Debug::MDEBUG_COLORS[:lineno].id }}m{{ line }}\e[0m",
      "\e[38;5;{{ ::Debug::MDEBUG_COLORS[:separator].id }}m -- \e[0m",
      "\e[38;5;{{ ::Debug::MDEBUG_COLORS[:message].id }}m{{ message.id }}\e[0m"].join("")
    %}
  {% end %}
end

require "debug/src/debug/**"

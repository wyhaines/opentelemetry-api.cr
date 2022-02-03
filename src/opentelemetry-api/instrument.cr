module OpenTelemetry
  abstract class Instrument
    getter name : String
    getter key_name : String = ""
    getter kind : String
    getter unit : String = ""
    getter description : String = ""
    property attributes : Hash(String, AnyAttribute) = {} of String => AnyAttribute
    property labels : Hash(String, String) = {} of String => String

    def initialize(@name, @kind, @unit = "", @description = "")
      validate_fields
      set_key_name
    end

    private def validate_fields
      validate_name
      validate_kind
      validate_unit
    end

    private def validate_name
      message = if @name.nil || @name.empty?
                  "Instrument names can not be empty"
                elsif @name !~ /^[a-zA-Z]/
                  "Instrument names must start with an alphabetic character"
                elsif @name !~ /^[a-zA-Z][a-zA-Z0-9_\-\.]*$/
                  "Instrument name must be comprised of only alphanumeric characters and '_', '.', and '-' characters"
                elsif @name.size > 63
                  "Instrument names must be less than 64 characters in length"
                else
                  nil
                end

      raise InstrumentNameError.new(message) if message
    end

    private def validate_kind
    end

    private def validate_unit
      raise InstrumentUnitError.new("Unit names must be less than 64 characters in length") if @unit.size > 63
    end

    private def set_key_name
      @key_name = @name.downcase
    end
  end
end

require "./instrument/*"

module OpenTelemetry
  alias Instruments = Instrument::Counter
end

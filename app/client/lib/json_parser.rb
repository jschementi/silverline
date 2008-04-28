require "Microsoft.Scripting"
include Microsoft::Scripting::Hosting

class JSONParser
  # TODO: remove when eval is implemented
  def evaluate(str)
    ScriptRuntime.
    create.
    get_engine("rb").
    create_script_source_from_string(str).
    execute
  end

  # TODO: remove this when Struct is working properly
  class AST
    def initialize(value)
      @value = value
    end
    def value
      @value
    end
  end

  def parse(input)
    @input = StringScanner.new(input)
    if top_level = parse_object || parse_array
      top_level.value
    else
      error("Illegal top-level JSON object")
    end
  end

  private

  def parse_value
    trim_space
    parse_object or
    parse_array or
    parse_string or
    parse_number or
    parse_keyword or
    error("Illegal JSON value")
  ensure
    trim_space
  end

  def parse_object
    if @input.scan(/\{\s*/)
      object = Hash.new
      more_pairs = false
      while true
        key = parse_string
        break if key == false
        @input.scan(/\s*:\s*/) or error("Expecting object separator")
        object[key.value] = parse_value.value
        more_pairs = @input.scan(/\s*,\s*/) or break
      end
      error("Missing object pair") if more_pairs
      @input.scan(/\s*\}/) or error("Unclosed object")
      AST.new(object)
    else
      false
    end
  end

  def parse_array
    if @input.scan(/\[\s*/)
      array = Array.new
      more_values = false
      while true
        contents = begin
          parse_value
        rescue
          nil
        end
        break if contents == false or contents.nil?
        array << contents.value
        more_values = @input.scan(/\s*,\s*/) or break
      end
      error("Missing value") if more_values
      @input.scan(/\s*\]/) or error("Unclosed array")
      AST.new(array)
    else
      false
    end
  end

  def parse_string
    if @input.scan(/"/)
      string = String.new
      while true
        contents = parse_string_content
        contents = parse_string_escape if contents == false
        break if contents == false
        string << contents.value
      end
      @input.scan(/"/) or error("Unclosed string")
      AST.new(string)
    else
      false
    end
  end

  def parse_string_content
    if @input.scan(/[^\\"]+/)
      AST.new(@input.matched)
    else
      false
    end
  end

  def parse_string_escape
    if @input.scan(%r{\\["\\/]})
      AST.new(@input.matched[-1])
    elsif @input.scan(/\\[bfnrt]/)
      AST.new(evaluate(%Q{"#{@input.matched}"}))
    elsif @input.scan(/\\u[0-9a-fA-F]{4}/)
      AST.new([Integer("0x#{@input.matched[2..-1]}")].pack("U"))
    else
      false
    end
  end

  def parse_number
    if @input.scan(/-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?\b/)
      AST.new(evaluate(@input.matched))
    else
      false
    end
  end

  def parse_keyword
    if @input.scan(/\b(?:true|false|null)\b/)
      matched = @input.matched == "null" ? "nil" : @input.matched
      val = evaluate(matched)
      AST.new(val)
    else
      false
    end
  end

  def trim_space
    @input.scan(/\s+/)
  end

  def error(message)
    if @input.eos?
      raise "Unexpected end of input."
    else
      raise "#{message}: #{@input.peek(@input.string.length)}"
    end
  end
end

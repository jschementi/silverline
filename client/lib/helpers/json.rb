require 'strscan'

class JSON

  def self.parse(input)
    JSON.new.parse(input)
  end

  AST = Struct.new(:value)

  def parse(input)
    @input = StringScanner.new(input)
    if top_level = parse_object || parse_array
      top_level.value
    else
      error("Illegal top-level JSON object")
    end
  ensure
    @input.eos? or error("Unexpected data")
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
        while key = parse_string
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
        while contents = parse_value rescue nil
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
        while contents = parse_string_content || parse_string_escape
          string << contents.value
        end
        @input.scan(/"/) or error("Unclosed string")
        AST.new(string)
      else
        false
      end
    end
  
    def parse_string_content
      @input.scan(/[^\\"]+/) and AST.new(@input.matched)
    end
  
    def parse_string_escape
      if @input.scan(%r{\\["\\/]})
        AST.new(@input.matched[-1])
      elsif @input.scan(/\\[bfnrt]/)
        AST.new(eval(%Q{"#{@input.matched}"}))
      elsif @input.scan(/\\u[0-9a-fA-F]{4}/)
        AST.new([Integer("0x#{@input.matched[2..-1]}")].pack("U"))
      else
        false
      end
    end
  
    def parse_number
      @input.scan(/-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?\b/) and
      AST.new(eval(@input.matched))
    end
  
    def parse_keyword
      @input.scan(/\b(?:true|false|null)\b/) and
      AST.new(eval(@input.matched.sub("null", "nil")))
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

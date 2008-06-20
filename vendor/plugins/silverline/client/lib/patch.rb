
# Filling in the holes of IronRuby

# Add the Ruby standard library to the path
$: << "lib/std"

# Need attr* methods since in SL they throw a MethodAccessException
# when trying to be used
class Object
  def self.attr(symbols, writable = false)
    self.attr_reader(symbol)
    self.attr_writer(symbol) if writable
  end
  
  def self.attr_reader(*symbols)
    symbols.each do |symbol|
      define_method symbol do
        instance_variable_get(:"@#{symbol}")
      end
    end
  end
  
  def self.attr_writer(*symbols)
    symbols.each do |symbol|
      define_method(:"#{symbol}=") do |val|
        instance_variable_set(:"@#{symbol}", val)
      end
    end
  end
  
  def self.attr_accessor(*symbols)
    self.attr_reader(*symbols)
    self.attr_writer(*symbols)
  end
end

class DateTime
  def to_s
    to_string
  end
end

# TODO: this is part of ActiveSupport, and shouldn't be in the ruby patch file. 
# Move this out to the Rails folder, but load it early on
module Inflection
  def self.underscore(camel_cased_word)
    camel_cased_word.to_s.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
  
  def self.constantize(camel_cased_word)
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
      raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
    end

    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  end
end

# Filling in the holes of IronRuby

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
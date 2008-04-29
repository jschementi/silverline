# Filling in the holes of IronRuby

class Object
  def self.attr(symbol, writable = false)
    attr_reader symbol
    attr_writer symbol if writable
  end
  
  def self.attr_reader(symbol)
    define_method symbol do
      instance_variable_get(:"@#{symbol}")
    end
  end
  
  def self.attr_writer(symbol)
    define_method(:"#{symbol}=") do |val|
      instance_variable_set(:"@#{symbol}", val)
    end
  end
  
  def self.attr_accessor(symbol)
    attr_reader symbol
    attr_writer symbol
  end
end

class Hash
  def [](index)
    fetch(index) { |i| fetch(i.kind_of?(String) ? i.to_sym : i.to_s) }
  end
end

class DateTime
  def to_s
    to_string
  end
end
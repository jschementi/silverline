require 'lib/helpers/html/patch'
include System::Windows::Browser

module Html
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def document
      HtmlPage.document
    end
  end
  
  def document
    self.class.document
  end
  
  def tag(tag, options = {})
    output = "<#{tag}"
    options.each {|k,v| output << " #{k}=\"#{v}\""}
    if block_given?
      output << ">"
      output << yield
      output << "</#{tag}>"
    else
      output << " />"
    end
    output
  end
  
end

$d = HtmlPage.document
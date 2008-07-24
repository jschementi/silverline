include System::Windows
include System::Windows::Browser

module Debug
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)	
  end
  
  module ClassMethods
    def puts(msg)
      div = HtmlPage.document.get_element_by_id('debug_print')
      if div.nil?
        div = HtmlPage.document.create_element('div')
        div.set_attribute('id', "debug_print")
        HtmlPage.document.get_elements_by_tag_name("body").get_Item(0).append_child(div)
      end
      div.set_property('innerHTML', "#{div.get_property('innerHTML')}<hr />#{msg}")
    end
            
    def log(msg)
      self.puts(msg) if $DEBUG
    end
  end
  
  module InstanceMethods
    def puts(msg)
      self.class.puts(msg)
    end
  
    def log(msg)
      self.class.log(msg)
    end
  end
end

class Logger
  def debug(msg)
    puts msg
  end
private
  include Debug
end

def logger
  Logger.new
end
$logger = logger

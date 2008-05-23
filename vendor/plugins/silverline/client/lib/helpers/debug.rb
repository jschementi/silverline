module Debug
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)	
  end
  
  module ClassMethods
    def puts(msg)
      if document.get_element_by_id('debug_print').nil?
        div = document.create_element('div')
        div[:id] = "debug_print"
        document.get_elements_by_tag_name("body").get_Item(0).append_child(div)
      end
      dp = document.get_element_by_id('debug_print')
      dp.set_property('innerHTML', "#{dp.get_property('innerHTML')}<hr />#{msg}")
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

module Debug
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)	
  end
  
  module ClassMethods
	  def puts(msg)
	    if document.debug_print.nil?
	      div = document.create_element('div')
	      div[:id] = "debug_print"
	      document.get_elements_by_tag_name("body").get_Item(0).append_child(div)
	    end
	    document.debug_print[:innerHTML] = "#{document.debug_print.innerHTML}<hr />#{msg}"
	  end
		  
	  def debug_puts(msg)
	    self.puts(msg) if $DEBUG
	  end
  end
  
  module InstanceMethods
	  def puts(msg)
	    self.class.puts(msg)
	  end
	
	  def debug_puts(msg)
	    self.class.debug_puts(msg)
	  end
  end
end
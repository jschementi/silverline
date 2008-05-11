module Debug
  def self.puts(msg)
    if document.debug_print.nil?
      div = document.create_element('div')
      div[:id] = "debug_print"
      document.get_elements_by_tag_name("body").get_Item(0).append_child(div)
    end
    document.debug_print[:innerHTML] = "#{document.debug_print.innerHTML}<hr />#{msg}"
  end
  def puts(msg)
    self.class.puts(msg)
  end

  def self.debug_puts(msg)
    puts(msg) if $DEBUG
  end
  def debug_puts(msg)
    self.class.debug_puts(msg)
  end
end
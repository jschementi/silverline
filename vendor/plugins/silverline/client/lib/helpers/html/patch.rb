include System::Windows::Browser

class HtmlDocument
  def method_missing(m)
    get_element_by_id(m)
  end

  alias_method :orig_get_element_by_id, :get_element_by_id
  def get_element_by_id(id)
    orig_get_element_by_id(id.to_s.to_clr_string)
  end
end

class HtmlElement
  def [](index)
    get_attribute(index)
  end

  def []=(index, value)
    set_attribute(index, value)
  end

  def method_missing(m, &block)
    if(block.nil?)
      self[m]
    else
      attach_event(m.to_s.to_clr_string, System::EventHandler.new(&block))
    end
  end

  def style
    HtmlStyle.new(self)
  end

  alias_method :orig_get_attribute, :get_attribute
  def get_attribute(index)
    orig_get_attribute(index.to_s.to_clr_string)
  end

  alias_method :orig_set_attribute, :set_attribute
  def set_attribute(index, value)
    orig_set_attribute(index.to_s.to_clr_string, value)
  end

  alias_method :orig_get_style_attribute, :get_style_attribute
  def get_style_attribute(index)
    orig_get_style_attribute(index.to_s.to_clr_string)
  end

  alias_method :orig_set_style_attribute, :set_style_attribute
  def set_style_attribute(index, value)
    orig_set_style_attribute(index.to_s.to_clr_string, value)
  end
end

class HtmlStyle
  def initialize(element)
    @element = element
  end

  def [](index)
    @element.get_style_attribute(index)
  end 

  def []=(index, value)
    @element.set_style_attribute(index, value)
  end

  def method_missing(m)
    self[m]
  end
end
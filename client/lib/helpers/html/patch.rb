include System::Windows::Browser

class HtmlDocument
  def method_missing(m, *args)
    super
  rescue => e
    id = get_element_by_id(m)
    return id unless id.nil?
    raise e  
  end

  alias_method :orig_get_element_by_id, :get_element_by_id
  def get_element_by_id(id)
    orig_get_element_by_id(id.to_s.to_clr_string)
  end
  
  alias_method :orig_get_elements_by_tag_name, :get_elements_by_tag_name
  def get_elements_by_tag_name(name)
    orig_get_elements_by_tag_name(name.to_s.to_clr_string)
  end
  
  def tags(name)
    get_elements_by_tag_name name
  end
end

class HtmlElementCollection
  def [](index)
    get_Item(index)
  end
  def size
    count
  end
  def first
    self[0] if size > 0
  end
  def last
    self[size - 1] if size > 0
  end
  def empty?
    size == 0
  end
end

require 'lib/rquery/manipulation'

class HtmlElement
  include RQuery::Manipulation::ChangingContents
  include RQuery::Manipulation::InsertingInside
  include RQuery::Manipulation::InsertingOutside
  include RQuery::Manipulation::InsertingAround
  include RQuery::Manipulation::Replacing
  include RQuery::Manipulation::Removing
  include RQuery::Manipulation::Copying
  
  def [](index)
    val = get_attribute(index)
    return get_property(index) if val.nil?
    return val
  end

  def []=(index, value)
    val = get_attribute(index)
    val.nil? ? set_property(index, value) : set_attribute(index, value)
  end

  def method_missing(m, *args, &block)
    super
  rescue => e
    if block.nil?
      if m.to_s[-1..-1] == "="
        self[m.to_s[0..-2]] = args.first
      else
        id = self[m] 
        return id unless id.nil?
        raise e
      end
    else
      # TODO: want to do EventHandler.of(HtmlEventArgs) to get proper arguments back
      unless attach_event(m.to_s.to_clr_string, System::EventHandler.of(HtmlEventArgs).new(&block))
        raise e
      end
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

  alias_method :orig_get_property, :get_property
  def get_property(index)
    orig_get_property(index.to_s.to_clr_string)
  end

  alias_method :orig_set_property, :set_property
  def set_property(index, value)
    orig_set_property(index.to_s.to_clr_string, value)
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

  def method_missing(m, *args)
    super
  rescue => e
    if m.to_s[-1..-1] == "="
      self[m.to_s[0..-2]] = args.first
    else
      style = self[m]
      return style unless style.nil?
      raise e
    end
  end
end

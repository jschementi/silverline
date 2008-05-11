# Ruby Silverlight helpers
# Same functions/behavior as the Prototype Helper of Rails, so any rjs calls
# can be run on the client.
class RSL
  
  def initialize(document)
    @document = document
  end
  
  def insert_html(position, element, string)
    e = @document.send(element)
    unless e.nil?
      e[:innerHTML] = "#{e[:innerHTML]} #{string}"
    end
  end
  
end
# Controller base-class which allows children to run their actions on the client. 
#
# This is the client-side implementation whichkeeps track of the Silverlight
# host and provides rendering abilities
class ApplicationController
  def self.client(*args)
    # Empty on purpose; not used on the client
  end
  
  attr_accessor :host

  def render(options, &block)
  	if options == :update
	    rjs = RSL.new(host.document)
	    yield rjs unless block.nil?
	else
		# TODO: other render options
	end
  end
end

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
require 'lib/rails'

# Controller base-class which allows children to run their actions on the client. 
#
# This is the client-side implementation which keeps track of the Silverlight
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
module Silverline::Visualize
  # Nothing on purpose =)
end

require 'silverline/visualize/rendering'

ActionController::Base.class_eval do 
protected
  include Silverline::Visualize::Rendering
end
ActionView::Base.class_eval do
  include Silverline::Visualize::Rendering
end
module Silverline::Visualize
  # Nothing on purpose =)
end

require 'silverline/visualize/controller'
ActionController::Base.class_eval do 
  include Silverline::Visualize::Controller
end
ActionView::Base.class_eval do
  include Silverline::Visualize::Controller
end
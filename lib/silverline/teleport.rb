module Silverline::Teleport
  # Nothing on purpose =)
end

require 'silverline/teleport/controller'
require 'silverline/teleport/view'
require 'silverline/teleport/html'
require 'silverline/teleport/rendering'

ActionController::Base.class_eval do
protected
  include Silverline::Teleport::Controller
  include Silverline::Teleport::Rendering
end
ActionView::Base.class_eval do
  include Silverline::Teleport::View
  include Silverline::Teleport::Html
  include Silverline::Teleport::Rendering
end
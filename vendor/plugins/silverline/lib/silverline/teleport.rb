module Silverline::Teleport
  # Nothing on purpose =)
end

require 'silverline/teleport/controller'
require 'silverline/teleport/view'
require 'silverline/teleport/html'
ActionController::Base.class_eval do
  include Silverline::Teleport::Controller
end
ActionView::Base.class_eval do
  include Silverline::Teleport::View
  include Silverline::Teleport::Html
end
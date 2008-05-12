module Silverline::Essential
  # Nothing on purpose =)
end

require 'silverline/essential/generator'
Silverline::Essential::Generator.register

require 'silverline/essential/html'
ActionView::Base.class_eval do 
  include Silverline::Essential::Html
end
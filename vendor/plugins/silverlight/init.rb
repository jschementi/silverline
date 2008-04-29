require 'generator'
require 'silverlight'
ActionView::Base.class_eval do 
  include ActionView::Helpers::SilverlightHelper
  alias_method_chain :render, :silverlight
end
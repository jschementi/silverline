module Silverline::Essential
  
  # make sure to undefine Xap if it already exists; this file should always
  # have first crack at defining it
  instance_eval { remove_const :Xap } if defined?(Xap)
  
  # What should generate the Xap?
  # 
  #   Uses rubyzip to generate the XAP. This is the default behavior, so
  #   setting nothing is the same.
  #   Note: you can install rubyzip with "gem install rubyzip"
  # Xap = :rubyzip
  # 
  #   Uses Chiron.exe to generate the XAP
  #   Note: This requires mono installed on Linux/Mac 
  Xap = :chiron

end

if ENV['RAILS_ENV'] != 'production' 
  require 'silverline/essential/generator'
  Silverline::Essential::Generator.register 
end

require 'silverline/essential/html'
ActionView::Base.class_eval do 
  include Silverline::Essential::Html
end
module Silverline::Essential
  
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

require 'silverline/essential/generator'
Silverline::Essential::Generator.register

require 'silverline/essential/html'
ActionView::Base.class_eval do 
  include Silverline::Essential::Html
end
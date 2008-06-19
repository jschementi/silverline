dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
#$_spec_spec = true # Prevents Kernel.exit in various places

require 'spec'
require 'spec/mocks'

require File.dirname(__FILE__) + '/matchers/relative_rails_root.rb'

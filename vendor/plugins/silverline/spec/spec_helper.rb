dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'rubygems'
require 'spec'
require 'spec/mocks'

require dir + '/matchers/relative_rails_root.rb'
Spec::Runner.configure do |config|
  config.include(CustomPathMatchers)
end

ENV = {} unless defined?(ENV)
ENV['RAILS_ENV'] = 'test'
RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + "/../../../../") unless defined? RAILS_ROOT
ActionController = Module.new unless defined? ActionController
ActionController::Base = Class.new unless defined? ActionController::Base
ActionView = Module.new unless defined? ActionView
ActionView::Base = Class.new unless defined? ActionView::Base

require 'patch/ruby'
require 'silverline'

Silverline::Essential = Module.new unless defined? Silverline::Essential
Silverline::Visualize = Module.new unless defined? Silverline::Visualize
Silverline::Teleport = Module.new unless defined? Silverline::Teleport

def dbg
  require 'ruby-debug'
  debugger
end


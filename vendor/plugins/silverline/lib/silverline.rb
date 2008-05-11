require 'patch/ruby'

module Silverline
  RAILS_VIEWS = "#{RAILS_ROOT}/app/views/"
  XAP_FILE = "#{RAILS_ROOT}/public/client.xap"
  CLIENT_ROOT = "#{RAILS_ROOT}/lib/client"
  TMP_CLIENT = "#{RAILS_ROOT}/tmp/client"
  PLUGIN_ROOT = "#{RAILS_ROOT}/vendor/plugins/silverline"
  PLUGIN_CLIENT = "#{PLUGIN_ROOT}/client"
  module FileExtensions
    WPF = "wpf.rb"
    XAML_ERB = "xaml.erb"
    XAML = "xaml"
    RB = "rb"
  end
end

require 'silverline/essential'
require 'silverline/visualize'
require 'silverline/teleport'
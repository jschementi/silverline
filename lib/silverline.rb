unless defined? ::RAILS_ROOT
  RAILS_ROOT = File.dirname(__FILE__) + "../"
end

module Silverline
  RAILS_VIEWS = "#{::RAILS_ROOT}/app/views"
  RAILS_CTRLRS = "#{::RAILS_ROOT}/app/controllers"
  RAILS_MODELS = "#{::RAILS_ROOT}/app/models"
  XAP_FILE = "#{::RAILS_ROOT}/public/client.xap"
  CLIENT_ROOT = "#{::RAILS_ROOT}/lib/client"
  TMP_CLIENT = "#{::RAILS_ROOT}/tmp/client"
  PLUGIN_ROOT = "#{::RAILS_ROOT}/vendor/plugins/silverline"
  PLUGIN_CLIENT = "#{PLUGIN_ROOT}/client"
  module FileExtensions
    WPF = "wpf.rb"
    XAML_ERB = "xaml.erb"
    XAML = "xaml"
    RB = "rb"
  end
end

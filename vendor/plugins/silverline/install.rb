# Install hook code here
require 'ftools'
require 'silverline'

FileUtils.cp_r "#{Silverline::PLUGIN_ROOT}/public/.", "#{RAILS_ROOT}/public"
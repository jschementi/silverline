# Install hook code here
require 'ftools'
require 'silverline'

public_dir = "#{RAILS_ROOT}/public"
FileUtils.cp_r "#{Silverline::PLUGIN_ROOT}/public/.", public_dir
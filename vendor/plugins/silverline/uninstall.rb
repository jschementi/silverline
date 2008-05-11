# Uninstall hook code here
require 'ftools'
require 'silverline'

FileUtils.rm_r "#{RAILS_ROOT}/public/ironruby"
FileUtils.rm "#{RAILS_ROOT}/public/clientaccesspolicy.xml"
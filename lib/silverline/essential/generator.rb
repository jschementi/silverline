# NOTE: requires filesystemwatcher to be installed
# http://www.jhorman.org/FileSystemWatcher/index.html
require "filesystemwatcher/filesystemwatcher"

require 'fileutils'
require 'silverline/essential/xap'

def logger
  ::RAILS_DEFAULT_LOGGER
end

# Generates the XAP on modification of watched files
module Silverline::Essential::Generator

  # List of files/directories to watch for modification.
  # Triggers generation of the Silverlight package (XAP)
  def self.register
    create_directories
    @watcher = FileSystemWatcher.new

    [Silverline::CLIENT_ROOT, Silverline::PLUGIN_CLIENT].each do |dir|
      @watcher.addDirectory dir
    end

    # TODO: watch all client controllers, as well as all views
    @watcher.addFile "#{RAILS_ROOT}/app/controllers/client_controller.rb"
    @watcher.addDirectory Silverline::RAILS_VIEWS
    
    @watcher.sleepTime = 1
    @watcher.start { |status, file| generate }
    generate # make sure to generate XAPs the first time
  end
  
  def self.generate
    logger.info "Silverline: Generating client.xap"
    %W(#{Silverline::XAP_FILE}).each do |file|
      File.delete(file) if File.exists?(file)
    end
    
    # First copy the plugin's client folder to tmp folder
    FileUtils.cp_r "#{Silverline::PLUGIN_CLIENT}/.", Silverline::TMP_CLIENT
    
    # TODO: should the controller/views be handled by Visualize/Teleport?
    # TODO: copy all controllers, views, and models to tmp folder
    FileUtils.mkdir_p "#{Silverline::TMP_CLIENT}/controllers"
    FileUtils.mkdir_p "#{Silverline::TMP_CLIENT}/views"
    FileUtils.cp 'app/controllers/client_controller.rb', "#{Silverline::TMP_CLIENT}/controllers"
    FileUtils.cp_r "#{Silverline::RAILS_VIEWS}/.", "#{Silverline::TMP_CLIENT}/views"
    
    # Lastly, client root wins
    FileUtils.cp_r "#{Silverline::CLIENT_ROOT}/.", Silverline::TMP_CLIENT
    Silverline::Essential::XAP.new(Silverline::XAP_FILE, Silverline::TMP_CLIENT).generate
    
    FileUtils.rm_r Silverline::TMP_CLIENT
  end

  def self.create_directories
    FileUtils.mkdir_p Silverline::TMP_CLIENT
    FileUtils.mkdir_p Silverline::CLIENT_ROOT
  end
end

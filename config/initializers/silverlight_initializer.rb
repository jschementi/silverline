# NOTE: requires filesystemwatcher to be installed
# http://www.jhorman.org/FileSystemWatcher/index.html
require "filesystemwatcher"

class << Class
  def cattr_reader(*syms)
    syms.flatten.each do |sym|
      next if sym.is_a?(Hash)
      class_eval("
        unless defined? @@#{sym}\n
          @@#{sym} = nil\n
        end\n
        def self.#{sym}\n
          @@#{sym}\n
        end\n
        def #{sym}\n
          @@#{sym}\n
        end\n", __FILE__, __LINE__)
    end
  end
end

module ClientGenerator
  def build_xap
    FileUtils.mkdir_p 'app/.client/controllers'
    FileUtils.cp_r 'app/client/.', 'app/.client'
    FileUtils.cp 'app/controllers/client_controller.rb', 'app/.client/controllers'
    yield
    FileUtils.rm_r 'app/.client'
  end
end

# Handles packaging the Silverlight application with Chiron, a .NET console
# application written in C#. It handles generation of the AppManifest.xaml, as
# well as packaging the app and including language assemblies if needed.
# Note: because Chiron is a .NET application, it requires mono to run on 
# Mac/Linux. If you don't want to install mono, use the pure-ruby XAP module.
class XAPChiron
  def generate
    cmd = "public/ironruby/Chiron.exe /s /d:app/.client /z:public/client.xap"
    # XXX: Should I do some platform detection rather than trial&error?
    system "#{cmd}" unless system "mono #{cmd}"
  end
end

# Handles packaging the Silverlight application.
class XAP
  # require rubyzip (gem install rubyzip | http://rubyzip.sourceforge.net/)
  require 'zip/zipfilesystem'
  require 'erb'
  
  def generate
    Zip::ZipFile.open "public/client.xap", Zip::ZipFile::CREATE do |zip|
      xap zip, "app/.client"
      zip.file.open "AppManifest.xaml", 'w' do |m| 
        m.puts manifest
        @files << "AppManifest.xaml"
      end
    end
    # Remove temp files left behind by rubyzip
    # Bug: http://sourceforge.net/tracker/index.php?func=detail&aid=1702240&group_id=43107&atid=435170
    @files.each do |file|
      file = file.split("/").last
      Dir["public/#{file}.*"].each do |f|
        File.delete f
      end
    end
    @files = []
  end
  
  def manifest
    @assembly_path = "/public/ironruby"
    # Note: Silverlight entry-point assembly must be the first in this list
    # (Microsoft.Scripting.Silverlight in this case)
    @assemblies = %w(Microsoft.Scripting.Silverlight Microsoft.Scripting IronRuby IronRuby.Libraries)
    @entry_point_type = "Microsoft.Scripting.Silverlight.DynamicSilverlight"
    file = File.open("AppManifest.erb.xaml", 'r')
    xaml = ERB.new file.read
    xaml.run(binding)
  end

  def xap(zip, dir, root = dir)
    Dir["#{dir}/*"].each do |client|
      short_client = client.split(root).last
      if File.directory? client
        zip.dir.mkdir short_client
        xap zip, client, root
      else
        zip.file.open short_client, 'w' do |zf|
          f = File.open client
          zf.puts f.read
          f.close
        end
      end
      @files << short_client
    end
  end
end

# Integrates Silverlight into Rails
# Note: you must restart your server if you modify this file
class SilverlightInitializer
  include ClientGenerator
  
  def initialize
    @files = []
    class << @files
      alias :"old_carot" :"<<"
      def << (val)
        puts val
        old_carot val
      end
    end
    
    # generate every time the client directory is modified
    @watcher = FileSystemWatcher.new
    @watcher.addDirectory "#{RAILS_ROOT}/app/client"
    @watcher.addFile "#{RAILS_ROOT}/app/controllers/client_controller.rb"
    @watcher.sleepTime = 1
    @watcher.start { |status, file| generate }
    
    puts "** Initializing Silverlight"
    # generate when server starts
    generate
  end
  
  def generate
    ["public/client.xap"].each do |file|
      File.delete(file) if File.exists?(file)
    end
    puts "** Generating client.xap"
    build_xap do 
        # TODO: If I can find a ruby zip library (RubyZip) that works for 
        #       Silverlight, use the following line instead:
        # XAP.generate
        XAPChiron.new.generate
    end
  end
end

SilverlightInitializer.new
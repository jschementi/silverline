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
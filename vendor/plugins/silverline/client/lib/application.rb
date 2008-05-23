require 'lib/patch'
require 'lib/helpers'
require 'lib/rails'

include System::Windows
include System::Windows::Browser

class SilverlightApplication
  include Downloader
  include Html
  include Wpf
  include Debug
  
  attr_reader :params
  
  def initialize
    $app = self
    @params = $PARAMS
  end
 
  def application
    Application.current
  end
  
  def method_missing(m)
    super
  rescue => e
    begin
      return element = root.send(m)
    rescue 
      begin
        return element = document.send(m)
      rescue
        raise e
      end
    end
  end
  
  def dejsonify(o)
    JSON.new.parse(o.replace("==>", ",").replace("'", "\""))
  end
  
  def render(options = {})
    split_url = options[:partial].split "/"
    split_url[-1] = "_#{split_url[-1]}"
    partial = split_url.join "/"

    path = params[:rb_to_run].to_s.split("/")[0..-2].join("/") unless params[:rb_to_run].nil?
    filename = "#{path}/#{partial}.html.erb"
    begin
      XAP.get_file(filename)
    rescue
      filename = "views/#{partial}.html.erb"
    end
    
    rhtml = ERB.new XAP.get_file_contents(filename)
    document.send(options[:update])[:innerHTML] = rhtml.result(binding)
  end
end

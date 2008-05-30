require 'lib/patch'
require 'lib/helpers'
require 'lib/rails'

include System::Windows
include System::Windows::Browser
include System::Windows::Interop

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
    ["html.erb", "xaml"].each do |ext|
      ["#{path}/#{partial}", "views/#{partial}"].each do |search_path|
        filename = "#{search_path}.#{ext}"
        next unless XAP.get_file(filename)
        send("render_#{ext.split(".").join("_")}", filename, options)
        return
      end
    end
    raise Exception.new("#{partial} partial not found")
  end

private

  def render_html_erb(filename, options)
    rhtml = ERB.new XAP.get_file_contents(filename)
    document.send(options[:update]).innerHTML = rhtml.result(binding)
  end

  def render_xaml(filename, options)
    type_str = options[:properties].nil? ? nil : options[:properties][:type]
    type = (type_str.nil? ? UserControl : Inflection.constantize(type_str)).new
    Application.load_component(type, Uri.new(filename, UriKind.Relative))
    Application.current.root_visual = type
  end
end

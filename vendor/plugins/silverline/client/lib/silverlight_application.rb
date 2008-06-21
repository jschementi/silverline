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
    split_url = options[:partial].to_s.split "/"
    split_url[-1] = "_#{split_url[-1]}" if split_url[-1][0..0] != "_"
    partial = split_url.join "/"
    
    path = params[:rb_to_run].to_s.split("/")[0..-2].join("/") unless params[:rb_to_run].nil?
    search_paths = []
    search_paths << "#{path}/#{partial}" unless path.nil?
    search_paths << (partial.clone[0..5] == "views/" ? partial : "views/#{partial}")
    
    ["html.erb", "xaml", "xaml.erb"].each do |ext|
      search_paths.each do |search_path|
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
    element = get_type(options).new
    
    Application.load_component(element, Uri.new(filename, UriKind.Relative))
    Application.current.root_visual = element
  end 
  
  def render_xaml_erb(filename, options)
    rxaml = XAP.get_file_contents(filename).to_s
    rxaml = rxaml.gsub /x:Class="#{get_type(options).to_s.gsub("::", ".")}"/, ""
    erb = ERB.new(rxaml, nil, "%-<>").result(binding)
    Application.current.root_visual = Markup::XamlReader.Load erb
  end
    
  def get_type(options)
    type = options[:properties].nil? ? nil : options[:properties][:type]
    if type.nil?
      UserControl
    elsif type.kind_of?(String)
      Inflection.constantize(type)
    else
      type
    end
  end

end

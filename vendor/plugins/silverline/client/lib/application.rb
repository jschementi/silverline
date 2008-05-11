require 'lib/patch'
require 'lib/helpers'

include System::Windows
include System::Windows::Browser

class SilverlightApplication
  include Downloader
  #include Debug
  # TODO: remove these methods when "extend" is implemented
  def self.puts(msg)
    if document.debug_print.nil?
      div = document.create_element('div')
      div[:id] = "debug_print"
      document.get_elements_by_tag_name("body").get_Item(0).append_child(div)
    end
    document.debug_print[:innerHTML] = "#{document.debug_print.innerHTML}<hr />#{msg}"
  end
  def puts(msg)
    self.class.puts(msg)
  end
  def self.debug_puts(msg)
    puts(msg) if $DEBUG
  end
  def debug_puts(msg)
    self.class.debug_puts(msg)
  end
  
  include Html
  # TODO: remove these method when "extend" is added
  def self.document
    HtmlPage.document
  end
  
  include Wpf
  # TODO: remove this method when "extend" is implemented
  def self.use_xaml(options = {})
    options = {:type => UserControl, :name => "app"}.merge(options)
    type = options[:type].new
    Application.load_component(type, Uri.new("#{options[:name]}.xaml", UriKind.Relative))
    Application.current.root_visual = type
  end
  
  attr_reader :params
  
  def initialize
    $app = self
    @params = $PARAMS
  end
 
  def application
    Application.current
  end
  
  def method_missing(m)
    element = root.send(m)
    element = document.send(m) if element.nil?
    return element
  end
  
  def dejsonify(o)
    JSON.new.parse(o.replace("==>", ",").replace("'", "\""))
  end
  
  #def render(options = {})
  #  file = File.open("views/#{options[:view]}.erb.html", 'r')
  #  rhtml = ERB.new file.read
  #  document.send(options[:id])[:innerHTML] = rhtml.run(binding)
  #end
end
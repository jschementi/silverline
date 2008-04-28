require 'lib/silverlight'
require 'lib/json_parser'
require 'controllers/silverlight_controller'

# This is the Silverlight router for Rails Controllers. It first hooks
# any links marked as Silverlight links to the correct actions. When a client
# action is triggered, it figures out which Controller and Aciton to render
# 
# To hook Silverlight links, it takes one special initParam ":client_links", 
# which is a list of unique identifiers and url_for-action-syntax for all 
# the client links on the page. It then grabs those links and hooks them
# with the appropriate action.
class App < SilverlightApplication
  def initialize
    super
    unless params[:client_links].to_s == "null"
      client_links = JSONParser.new.parse(
        params[:client_links].replace("==>", ",").replace("'", "\""))
        
      titles = client_links.collect { |l| l['title'] }
      
      document.get_elements_by_tag_name("a").select { 
        |a| titles.include?(a[:title]) && a[:rel] == "silverlight".to_clr_string
      }.each do |a|
        link = client_links.select{ |l| l[:title] == a[:title] }.first
        unless link.nil?
          a.onclick { |s, e| do_action(link[:options]) }
          a.remove_attribute("title")
        end
      end
    end
  end
  
  def do_action(options)
    #TODO: don't hardcode controller!
    require 'controllers/client_controller'
    controller = ClientController 
    c = controller.new
    c.host = self
    c.send(options[:url][:action])
  end
end

class DateTime
  def to_s
    to_string
  end
end

$app = App.new
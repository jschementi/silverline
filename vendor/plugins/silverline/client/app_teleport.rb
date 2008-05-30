require 'silverlight'
require 'controllers/application'

# This is the Silverlight router for Rails Controllers. It first hooks
# any links marked as Silverlight links to the correct actions. When a client
# action is triggered, it figures out which Controller and Action to render
# 
# To hook Silverlight links, it takes one special initParam ":client_links", 
# which is a list of unique identifiers and url_for-action-syntax for all 
# the client links on the page. It then grabs those links and hooks them
# with the appropriate action.
class Teleport < SilverlightApplication
  def initialize
    super
    unless params[:client_links].to_s == "null"
      @client_links = dejsonify(params[:client_links])
      find_client_links.each { |a| hook_client_link(a) }
    end
  end
  
  private
  
    def find_client_links
      # TODO: FIX THIS HACK! it should be l['title'] in the block!
      titles = @client_links.collect { |l| l.values.last }
      t = document.get_elements_by_tag_name("a").first.title.to_s
      document.get_elements_by_tag_name("a").select {
        |a| titles.include?(a.title.to_s) && a.rel.to_s == "silverlight"
      }
    end
  
    def hook_client_link(a)
      # TODO: FIX THIS HACK! it should be l['title'] == a.title.to_s in the block!
      link = @client_links.select{ |l| l.values.last == a.title.to_s }.first
      unless link.nil?
        # TODO: FIX THIS HACK! it should be link['options'] in do_action
        a.onclick { |s, e| do_action(link.values.first) }
        a.remove_attribute("title")
      end
    end
  
    def do_action(options)
      #TODO: don't hardcode controller!
      require 'controllers/client_controller'
      controller = ClientController
      c = controller.new
      c.host = self
      # TODO: FIX THIS HACK! it should be c.send options["url"]["action"]
      c.send(options.values.first.values.first)
    end
end

Teleport.new

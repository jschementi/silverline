# Controller base-class which allows children to run their actions on the client.
#
# This is the server-side implementation which keeps track of the client 
# actions, as well as any links to client actions in the rendered action.
class ActionController::Base  
  
  # list of all client actions in this controller
  cattr_reader :client_actions
  
  # list of all the client links rendered during the current request
  attr_accessor :client_links

  # Used to mark an action as a client action
  #
  # class FooController < SilverlightApplication
  #   client :time
  #   def time
  #     @time = Time.now
  #   end
  # end
  #
  # In this example, the time action will be run and rendered on the client
  def self.client(*args)
    @@client_actions ||= []
    @@client_actions = @@client_actions + args
  end
  
  alias :old_render :render
  def render(options=nil, &block)
    old_render(options, &block)
  end
end

module ActionView::Helpers::SilverlightHelper
  def link_to_client(name, options, html_options)
    # TODO: change this to stop generating an unique hash in the title and
    # simply use link_to_remote. When silverlight updates any ajax links to 
    # client links, it can detect the url and fix it then.
    require 'digest/sha1'
    title = Digest::SHA1.hexdigest(url_for(options))
    self.controller.client_links ||= []
    self.controller.client_links << {:title => title, :options => options}
    %Q(<a href="#" rel="silverlight" title="#{title}">#{name}</a>)
  end
end

module ActionView::Helpers::PrototypeHelper
  alias :old_link_to_remote :link_to_remote
  def link_to_remote(name, options = {}, html_options = nil)
    klass, action = class_and_action_from options
    if !klass.client_actions.nil? and klass.client_actions.include? action.to_sym
      link_to_client name, options, html_options
    else
      old_link_to_remote name, options, html_options
    end
  end
private
  def class_and_action_from(options)
    [
      options[:url].has_key?(:controller) ? "#{options[:url][:controller].capitalize}Controller".constantize : self.controller.class,
      options[:url].has_key?(:action) ? options[:url][:action] : self.controller.action_name
    ]
  end
end

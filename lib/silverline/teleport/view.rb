module Silverline::Teleport::View
  
  def self.included(base)
    base.class_eval do 
      include InstanceMethods
      alias_method_chain :link_to_remote, :client
    end
  end
  
  module InstanceMethods
  
    def link_to_client(name, options, html_options)
      # TODO: change this to stop generating an unique hash in the title and
      # simply use link_to_remote. When silverlight updates any ajax links to 
      # client links, it can detect the url and fix it then.
      require 'digest/sha1'
      title = Digest::SHA1.hexdigest(url_for(options))
      self.controller.client_links ||= []
      self.controller.client_links << {:title => title, :options => options}
      %Q(<a href="javascript:void(0)" rel="silverlight" title="#{title}">#{name}</a>)
    end
  

    def link_to_remote_with_client(name, options = {}, html_options = nil)
      if is_client_action?(options)
        link_to_client name, options, html_options
      else
        link_to_remote_without_client name, options, html_options
      end
    end
    
  end
  
end
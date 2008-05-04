module ActionView::Helpers::PrototypeHelper
  
  def link_to_remote_with_client(name, options = {}, html_options = nil)
    klass, action = class_and_action_from options
    if !klass.client_actions.nil? and klass.client_actions.include? action.to_sym
      link_to_client name, options, html_options
    else
      link_to_remote_without_client name, options, html_options
    end
  end
  alias_method_chain :link_to_remote, :client
  
  private
    
    def class_and_action_from(options)
      [
        options[:url].has_key?(:controller) ? "#{options[:url][:controller].capitalize}Controller".constantize : self.controller.class,
        options[:url].has_key?(:action) ? options[:url][:action] : self.controller.action_name
      ]
    end
    
end
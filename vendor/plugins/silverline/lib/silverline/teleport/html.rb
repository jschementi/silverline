module Silverline::Teleport::Html
  
  def self.included(base)
    base.class_eval do 
      debugger
      alias_method_chain :generate_init_params, :client_links
    end
  end
  
  private
    
    def generate_init_params_with_client_links(options)
      debugger
      p = generate_init_params_without_client_links(options)
      if !self.controller.client_links.blank?
        p << ", client_links=#{jsonify(self.controller.client_links)}"
      end
      return p
    end
    
end
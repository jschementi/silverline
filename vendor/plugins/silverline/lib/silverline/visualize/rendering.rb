require 'ftools'

module Silverline::Visualize::Rendering
  
  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :silverlight
    end
  end
  
  def render_with_silverlight(options=nil, &block)
    send("_ag_render_for_#{options.class.to_s.downcase}", options, &block)
  end
  
  private

    # Fallback to default Rails render()
    def _ag_render_without_silverlight(key, template, options, &block)
      render_without_silverlight({key => template}.merge(options), &block)
    end
    
    # See visualize/helpers for what gets included here
    include Helpers
    
end
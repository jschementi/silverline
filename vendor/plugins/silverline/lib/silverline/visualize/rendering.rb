require 'ftools'

module Silverline::Visualize::Rendering
  
  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :silverlight
    end
  end
  
  def render_with_silverlight(options=nil, other = {}, &block)
    send("_ag_render_for_#{options.class.to_s.downcase}", options, other, &block)
  end
  
  private

    # Fallback to default Rails render()
    def _ag_render_without_silverlight(key, template, options, other, &block)
      unless block.nil?
        render_without_silverlight({key => template}.merge(options), other, &block)
      else
        render_without_silverlight({key => template}.merge(options), other)
      end
    end
    
    # See visualize/helpers for what gets included here
    include Helpers
    
end
# Render based on the type passed to render's options parameter
module Silverline::Visualize::Helpers::Types
  include Templates
  
  def _ag_render_for_hash(options, other, &block)
    [:action, :partial, :inline, :template].each do |key|        
      if options.include?(key)
        template = options[key]
        options.delete(key)
        return send("__ag_render_a_#{key}", key, template, options, other, &block)
      end
    end
    render_without_silverlight(options, other, &block)
  end
  
  def _ag_render_for_symbol(option, other, &block)
    render_without_silverlight(option, &block)
  end
  
  def _ag_render_for_nilclass(options, other, &block)
    render_without_silverlight(options, &block)
  end
  
  def _ag_render_for_string(options, other, &block)
    render_without_silverlight(options, other, &block)
  end
  
end
# Render based on the template-key given in render(options)
module Silverline::Visualize::Helpers::Templates
  include Configuration
  include Formats
  
  # TODO: for now, actions bypass Silverlight altogether
  # Should this be different? Like, should someone be able to 
  # render a Ruby/XAML file without a RHTML file first?
  def __ag_render_a_action(key, template, options, &block)
    _ag_render_without_silverlight(key, template, options, &block)
  end
  
  def __ag_render_a_partial(key, template, options, &block)
    config = ___ag_options_for_render("_#{template}")
  
    # Render first type found
    # TODO: Make this work if the full filename is supplied
    [:ruby, :xaml].each do |type|
      if File.exists? send("___ag_#{type}_filename", config)
        return send("___ag_render_#{type}_partial", config[:filename], options)
      end
    end
  
    # Fallback to normal Rails rendering
    _ag_render_without_silverlight(key, template, options, &block)
  end
  
  # TODO: make inline Ruby/XAML work
  def __ag_render_a_inline(key, template, options, &block)
    _ag_render_without_silverlight(key, template, options, &block)
  end
  
  # TODO: make general template rendering for ruby/xaml work.
  # Not sure about actions (see above).
  def __ag_render_a_template(key, template, options, &block)
    _ag_render_without_silverlight(key, template, options, &block)
  end
  
end

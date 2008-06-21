# Render based on the template-key given in render(options)
module Silverline::Visualize::Helpers::Templates
  include Configuration
  include Formats
  
  # TODO: Ruby/XAML files should be supported actions
  def __ag_render_a_action(key, template, options, other, &block)
    _ag_render_without_silverlight(key, template, options, other, &block)
  end
  
  def __ag_render_a_partial(key, template, options, other, &block)
    config = ___ag_options_for_render("_#{template}")
  
    # Render first type found
    # TODO: Make this work if the full filename is supplied
    [:ruby, :xaml, :xaml_erb].each do |type|
      if File.exists? send("___ag_#{type}_filename", config)
        return send("___ag_render_#{type}_partial", config[:filename], options, other)
      end
    end
  
    # Fallback to normal Rails rendering
    _ag_render_without_silverlight(key, template, options, other, &block)
  end
  
  # TODO: make inline Ruby/XAML work
  def __ag_render_a_inline(key, template, options, other, &block)
    _ag_render_without_silverlight(key, template, options, other, &block)
  end
  
  # TODO: make general template rendering for ruby/xaml work.
  # Not sure about actions (see above).
  def __ag_render_a_template(key, template, options, other, &block)
    _ag_render_without_silverlight(key, template, options, other, &block)
  end
  
end

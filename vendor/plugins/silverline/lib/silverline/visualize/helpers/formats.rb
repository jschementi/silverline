# Rendering helpers based on the format of template being rendered
module Silverline::Visualize::Helpers::Formats
  
  def ___ag_render_ruby_partial(filename, options)
    return silverlight_object options.merge({
      :start => "views/#{@__cpath}/#{filename}"
    })
  end
  
  def ___ag_render_xaml_partial(filename, options)
    return silverlight_object options.merge({
      :start => "render_xaml",
      :xaml_to_render => "views/#{@__cpath}/#{filename}"
    })
  end
  
  def ___ag_ruby_filename(config)
    "#{config[:path]}#{config[:filename]}.#{config[:rb_ext]}"
  end
  
  def ___ag_xaml_filename(config)
    "#{config[:path]}#{config[:filename]}.#{config[:xaml_ext]}"
  end
  
end
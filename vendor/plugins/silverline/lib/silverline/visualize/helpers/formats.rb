# Rendering helpers based on the format of template being rendered
module Silverline::Visualize::Helpers::Formats
  
  def ___ag_render_ruby_partial(filename, options, other)
    return silverlight_object(options.merge({
      :start      => "app_render_rb",
      :rb_to_run  => "views/#{@__cpath}/#{filename}"
    }))
  end
  
  def ___ag_ruby_filename(config)
    "#{config[:path]}#{config[:filename]}.#{config[:rb_ext]}"
  end
  

  def ___ag_render_xaml_partial(filename, options, other)
    defaults = {
      :start          => "app_render_xaml",
      :xaml_to_render => "views/#{@__cpath}/#{filename}"
    }
    xaml_type = options[:properties].delete(:type)
    defaults[:xaml_type] = xaml_type unless xaml_type.nil?
    return silverlight_object(options.merge(defaults))
  end
  
  def ___ag_xaml_filename(config)
    "#{config[:path]}#{config[:filename]}.#{config[:xaml_ext]}"
  end
  
  
  def ___ag_render_xaml_erb_partial(filename, options, other)
    ___ag_render_xaml_partial(filename, options, other)
  end
  
  def ___ag_xaml_erb_filename(config)
    ___ag_xaml_filename(config) + ".erb"
  end
  
end

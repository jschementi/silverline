module Silverline::Visualize::Helpers::Configuration
  
  def ___ag_options_for_render(filename)
    @__cpath = self.respond_to?(:controller) ? self.controller.controller_path : self.controller_path
    {
      :filename =>  filename,
      :rb_ext =>    Silverline::FileExtensions::RB,
      :xaml_ext =>  Silverline::FileExtensions::XAML,
      :path =>      "#{Silverline::RAILS_VIEWS}/#{@__cpath}/"  
    }
  end
  
end
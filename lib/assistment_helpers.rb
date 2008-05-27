module AssistmentHelpers
  
  # finds the module name of a controller path
  def module_name
    @controller.controller_path.split("/").first
  end

  include Chrome
  include Navigation
  include Widgets
  include Render

end
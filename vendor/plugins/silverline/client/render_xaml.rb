require 'silverlight'
class RenderXaml < SilverlightApplication
  use_xaml :name => $params[:xaml_to_render]
end
RenderXaml.new
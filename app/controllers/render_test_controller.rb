class RenderTestController < ApplicationController
  layout "posts"
  
  def test_action_xaml
    render :action => "test_action_xaml"
  end
end

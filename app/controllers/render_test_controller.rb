class RenderTestController < ApplicationController
  layout "posts"
  
  def test_action_xaml
    render :action => "test_action_xaml", :properties => { :width => 640, :height => 480 }
  end
end

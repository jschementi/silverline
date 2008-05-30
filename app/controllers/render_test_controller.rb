class RenderTestController < ApplicationController
  
  def ruby_action
    
  end

  def ruby_partial
    render :action => 'clock_rb'
  end

  def xaml_action
    
  end

  def xaml_partial
    render :action => 'clock_xaml'
  end

end

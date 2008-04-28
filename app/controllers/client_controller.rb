class ClientController < ApplicationController
  client :time
  
  def index
    render :layout => true, :inline => <<-EOS
      <%= link_to_remote 'Show time', :url => {:action => 'time'} %>
      <br /><div id="time_div"></div>
    EOS
  end
 
  def time
    @time = Time.now
    render :update do |page|
      page.insert_html :bottom, 'time_div', "#{@time.to_s}<br />"
    end
  end
end

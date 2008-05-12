require 'silverlight'

class Posts < SilverlightApplication
  def start
    @posts = get "posts", :format => 'ruby'
    render :partial => "posts/posts", :update => "posts"
  end
end

Posts.new.start

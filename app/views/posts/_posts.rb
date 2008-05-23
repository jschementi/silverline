#get "posts", :format => 'ruby'
download "/posts.json" do |s, a|
  @posts = JSON.parse(a.result)
  render :partial => "posts", :update => "posts"
end

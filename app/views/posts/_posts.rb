download "/posts.json" do |s, a|
  @posts = JSON.new.parse(a.result)
  render :partial => "posts/posts", :update => "posts"
end

#get "posts", :format => 'ruby'
#render_posts :update => "posts"

def render_posts(options = {})
  id, posts = options[:update], @posts
  if @posts.empty?
    output = "No posts! Add one below!"
  else
    output = "<table>"
    output += "  <tr>"
    posts.first.keys.each do |key|
      output += "    <th>#{key}</th>"
    end
    output += "  </tr>"
    posts.each do |post|
      output += "  <tr>"
      post.keys.each do |key|
        output += "    <td>#{post[key]}</td>"
      end
      output += "  </tr>"
    end
    output += "</table>"
  end
  document.send(id)[:innerHTML] = output
end  

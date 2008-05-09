require 'silverlight'

class Posts < SilverlightApplication
  def initialize
    super
    result = download "/posts.json"
    @posts = JSONParser.new.parse(result)
    render_posts :id => "posts"
  end
  
  def render_posts(options = {})
    id, posts = options[:id], @posts
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
    document.send(id)[:innerHTML] = output
  end
end

Posts.new

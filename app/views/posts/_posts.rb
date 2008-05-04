require 'silverlight'

class Posts < SilverlightApplication
  def initialize
    super
    request = Net::WebClient.new
    request.download_string_completed do |s,a|
      @posts = JSONParser.new.parse(a.result)
      _render "posts", @posts
      #render :id => "posts", :view => "posts/index"
    end
    request.download_string_async Uri.new("http://#{params[:http_host]}/posts.json")
  end

  def _render(id, posts)
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

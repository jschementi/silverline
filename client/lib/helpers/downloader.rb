include System::Windows::Browser

module Downloader
  
  def download(url, &block)
    unless block_given?
      request = HtmlPage.Window.CreateInstance("XMLHttpRequest".to_clr_string)
      request.Invoke("open".to_clr_string, "GET".to_clr_string, url, false)
      request.Invoke("send".to_clr_string, "".to_clr_string)
      request.GetProperty("responseText".to_clr_string).to_s
    else
      request = Net::WebClient.new
      request.download_string_completed(&block)
      request.download_string_async Uri.new("http://#{params[:http_host]}#{url}")
    end
  end
  
  def get(url, options, &block)
    url = "/#{url}.json"
    return download url, block if block_given? 
    json = download url
    return JSON.new.parse(json) if options[:format] == 'ruby'
    return json
  end
  
end

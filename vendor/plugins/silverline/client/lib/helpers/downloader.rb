include System::Windows::Browser

module Downloader
  
  def download(url, &block)
    if block.nil?
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
    json = download "/#{url}.json"
    return JSON.new.parse(json) if options[:format] == 'ruby'
    return json
  end
  
end
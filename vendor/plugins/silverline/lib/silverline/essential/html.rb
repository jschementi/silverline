module Silverline::Essential::Html
  
  def silverlight_include_tag(options = :defaults)
    templatify("head.html.erb", binding)
  end
  
  def silverlight_object(options = {})
    require 'erb'
    defaults = {
      :start => "app",
      :debug => false,
      :reportErrors => "errorLocation",
      :properties => {
        :width => 1,
        :height => 1,
        :background => "#00ffffff",
        :windowless => true
      }
    }
    options = defaults.deep_merge(options)
    options[:start] << ".rb"
    retval = ""
    if options[:properties][:width].to_i < 2 || options[:properties][:height].to_i < 2
       retval << %Q(
       <style type='text/css'>
         #SilverlightControlHost {
         	position: absolute;
         }
       </style>
       )
    end
    retval << templatify("body.html.erb", binding)
  end
  
  private
  
    def http_host
      request = session.cgi.instance_variable_get(:"@request")
      return session.cgi.env_table['HTTP_HOST'] if request.nil?
      request.params["HTTP_HOST"]
    end

    def generate_init_params(options)
      options.delete(:properties)
      p = options.collect { |k,v| "#{k.to_s}=#{v.to_s}" }.join(", ") 
      p << ", http_host=#{http_host}"
    end

    def public_xap_file
      "/#{Silverline::XAP_FILE.split("/").last}"
    end
    
    def jsonify(o)
      o.to_json.gsub("\"", "'").gsub(",", "==>")
    end
    
    def templatify(path, b)
      ERB.new(File.open("#{Silverline::PLUGIN_ROOT}/templates/#{path}"){|f| f.read}).result(b)
    end
end

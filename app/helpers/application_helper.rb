# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def http_host
    session.cgi.instance_variable_get(:"@request").params["HTTP_HOST"]
  end
  
  def silverlight_include_tag(options)
    %Q(
      #{stylesheet_link_tag 'error'}
      <style type="text/css">
        #SilverlightControlHost {
          position: absolute;
        }
      </style>
      
      <!-- 
        Error handling for when DLR errors are disabled (with 
        reportErrors=false, or not defined at all)
      -->
      <script type="text/javascript">
        function onSilverlightError(sender, args) {
          if (args.errorType == "InitializeError")  {
            var errorDiv = document.getElementById("errorLocation");
            if (errorDiv != null)
              errorDiv.innerHTML = args.errorType + "- " + args.errorMessage;
          }
        }
      </script>
    )
  end
  
  def silverlight_object(options = {})
    defaults = {
      :start => "app",
      :debug => true,
      :reportErrors => "errorLocation"
    }
    options = defaults.merge(options)
    options[:start] << ".rb"
    %Q(
    <!--
      Syntax/Runtime errors from Silverlight will be displayed here.
      This will contain debugging information and should be removed
      or hidden when debugging is completed
    -->
    
    <div id='#{options[:reportErrors]}' style="font-size: small;color: Gray;"></div>
    
    <div id="debug_print"> </div> 
    
    <!-- 
      Silverlight control: allows us to write Ruby in the browser
    -->
    <div id="SilverlightControlHost" onload="self.focus()">
      <object data="data:application/x-silverlight," type="application/x-silverlight-2-b1" width="1" height="1">
        <param name="source" value="/client.xap" />
        <param name="onerror" value="onSilverlightError" />
        <param name="background" value="#ffffffff" />
        <param name="initParams" value="#{generate_init_params(options)}, http_host=#{http_host}, client_links=#{self.controller.client_links.to_json.gsub("\"", "'").gsub(",","==>") if self.controller.respond_to?("client_links")}" />
        <param name="windowless" value="true" />

        <a href="http://go.microsoft.com/fwlink/?LinkID=108182" style="text-decoration: none;">
          <img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none"/>
        </a>
      </object>
      <iframe style='visibility:hidden;height:0;width:0;border:0px'></iframe>
    </div>
    )
  end
  
  def generate_init_params(options)
    value = ""
    options.each do |k,v|
      value << "#{k.to_s}=#{v.to_s}, "
    end
    value[0..-3]
  end
  
end

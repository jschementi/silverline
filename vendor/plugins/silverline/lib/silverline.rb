require 'extensions'
require 'ftools'

# This is the server-side implementation which keeps track of the client 
# actions, as well as any links to client actions in the rendered action.
class ActionController::Base
  
  # list of all client actions in this controller
  cattr_reader :client_actions

  helper_method :silverlight_object
  
  # list of all the client links rendered during the current request
  attr_accessor :client_links

  # Used to mark an action as a client action
  #
  # class FooController < SilverlightApplication
  #   client :time
  #   def time
  #     @time = Time.now
  #   end
  # end
  #
  # In this example, the time action will be run and rendered on the client
  def self.client(*args)
    @@client_actions ||= []
    @@client_actions = @@client_actions + args
  end

  # Need to make sure @@client_actions is cleared after each request
  # since this class never gets reconstructed
  #after_filter :clear_client_actions_list
  after_filter :clear_client_actions
  def clear_client_actions
    @@client_actions = []
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
        <param name="initParams" value="#{generate_init_params(options)}, http_host=#{http_host}, client_links=#{client_links.to_json.gsub("\"", "'").gsub(",","==>") if self.respond_to?("client_links")}" />
        <param name="windowless" value="true" />

        <a href="http://go.microsoft.com/fwlink/?LinkID=108182" style="text-decoration: none;">
          <img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none"/>
        </a>
      </object>
      <iframe style='visibility:hidden;height:0;width:0;border:0px'></iframe>
    </div>
    )
  end

  private 
  
    def http_host
      session.cgi.instance_variable_get(:"@request").params["HTTP_HOST"]
    end

    def generate_init_params(options)
      value = ""
      options.each do |k,v|
        value << "#{k.to_s}=#{v.to_s}, "
      end
      value[0..-3]
    end

end

module ActionView::Helpers::SilverlightHelper
  
  def render_with_silverlight(options=nil, &block)
    if options[:partial]
      file = "#{RAILS_ROOT}/app/views/#{self.controller.controller_path}/_#{options[:partial]}.wpf.rb"
      if File.exists? file
        return silverlight_object options.merge(:start => "views/#{self.controller.controller_path}/_#{options[:partial]}.wpf") 
      end
    end
    render_without_silverlight(options, &block)
  end
  
  # TODO: move into ::AssetTagHelper
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
  
  def link_to_client(name, options, html_options)
    # TODO: change this to stop generating an unique hash in the title and
    # simply use link_to_remote. When silverlight updates any ajax links to 
    # client links, it can detect the url and fix it then.
    require 'digest/sha1'
    title = Digest::SHA1.hexdigest(url_for(options))
    self.controller.client_links ||= []
    self.controller.client_links << {:title => title, :options => options}
    %Q(<a href="#" rel="silverlight" title="#{title}">#{name}</a>)
  end
  
end

module ActionView::Helpers::PrototypeHelper
    
  alias :old_link_to_remote :link_to_remote
  def link_to_remote(name, options = {}, html_options = nil)
    klass, action = class_and_action_from options
    if !klass.client_actions.nil? and klass.client_actions.include? action.to_sym
      link_to_client name, options, html_options
    else
      old_link_to_remote name, options, html_options
    end
  end
  
  private
    
    def class_and_action_from(options)
      [
        options[:url].has_key?(:controller) ? "#{options[:url][:controller].capitalize}Controller".constantize : self.controller.class,
        options[:url].has_key?(:action) ? options[:url][:action] : self.controller.action_name
      ]
    end
    
end
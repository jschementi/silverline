# This is the server-side implementation which keeps track of the client 
# actions, as well as any links to client actions in the rendered action.
class ActionController::Base
  
  # list of all client actions in this controller
  cattr_reader :client_actions
  
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
  after_filter :clear_client_actions
  def clear_client_actions
    @@client_actions = []
  end
  
  def render_with_silverlight(options={}, &block)
    render_without_silverlight(options, &block)
  end
  alias_method_chain :render, :silverlight
  
  helper_method :silverlight_object
  def silverlight_object(options = {})
    require 'erb'
    defaults = {
      :start => "app",
      :debug => true,
      :reportErrors => "errorLocation",
      :properties => {
        :width => 1,
        :height => 1,
        :background => "#ffffffff",
        :windowless => true
      }
    }
    options = defaults.merge(options)
    options[:start] << ".rb"

    retval = ""
    if options[:properties][:width].to_i < 2 || options[:properties][:height].to_i < 2
       retval << ERB.new(File.open("#{Silverline::PLUGIN_ROOT}/templates/head.html.erb"){|f| f.read}).result(binding)
    end
    retval << ERB.new(File.open("#{Silverline::PLUGIN_ROOT}/templates/body.html.erb"){|f| f.read}).result(binding)
  end

  private 
    
    helper_method :render_ruby_partial
    def render_ruby_partial(filename, options)
      return silverlight_object options.merge({
        :start => "views/#{self.controller_path}/#{filename}"
      })
    end
    
    helper_method :render_xaml_partial
    def render_xaml_partial(filename, options)
      return silverlight_object options.merge({
        :start => "render_xaml",
        :xaml_to_render => "views/#{self.controller_path}/#{filename}"
      })
    end
      
    def http_host
      session.cgi.instance_variable_get(:"@request").params["HTTP_HOST"]
    end

    def generate_init_params(options)
      options.collect { |k,v| "#{k.to_s}=#{v.to_s}" }.join(", ")
    end

    def public_xap_file
      "/#{Silverline::XAP_FILE.split("/").last}"
    end

    def jsonify_client_links
      jsonify(client_links) if self.respond_to?("client_links")
    end
    
    def jsonify(o)
      o.to_json.gsub("\"", "'").gsub(",", "==>")
    end

end
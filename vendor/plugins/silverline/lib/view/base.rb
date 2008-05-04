require 'ftools'
require 'view/helpers/prototype_helper'

class ActionView::Base
  
  def render_with_silverlight(options=nil, &block)
    if options[:partial]
      cpath = self.controller.controller_path
      rb_ext, xaml_ext = Silverline::FileExtensions::RB, Silverline::FileExtensions::XAML
      path = "#{Silverline::RAILS_VIEWS}/#{cpath}/"
      filename = "_#{options[:partial]}"
      
      options.delete(:partial)
      
      # TODO: clean this up!
      unless File.exists? "#{path}#{filename}"
        if File.exists? "#{path}#{filename}.#{rb_ext}"
          return silverlight_object options.merge({
            :start => "views/#{cpath}/#{filename}"
          })
        elsif File.exists? "#{path}#{filename}.#{xaml_ext}"
          return silverlight_object options.merge({
            :start => "render_xaml",
            :xaml_to_render => "views/#{cpath}/#{filename}"
          })
        else
          return render_without_silverlight(options, &block)
        end
      else
        # TODO: Make all this work if the file is found!
        raise "Eek! Specifying the full filename is not supported!"
      end
    end
  end
  alias_method_chain :render, :silverlight
  
  # TODO: move into ::AssetTagHelper?
  def silverlight_include_tag(options)
    # TODO: ERb-ify this!
    %Q(
      #{stylesheet_link_tag 'error'}

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
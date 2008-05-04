require 'ftools'
require 'view/helpers/prototype_helper'

class ActionView::Base
  
  def render_with_silverlight(options={}, &block)
    filename = options[:action]
    filename = "_#{options[:partial]}" if options[:partial]
    rb_ext, xaml_ext = Silverline::FileExtensions::RB, Silverline::FileExtensions::XAML
    path = "#{Silverline::RAILS_VIEWS}/#{self.controller.controller_path}/"
  
    options.delete(:action)
    options.delete(:partial)
    
    # TODO: Make all this work if the full filename is supplied
    
    # Ruby Partial
    if File.exists? "#{path}#{filename}.#{rb_ext}"
      return render_ruby_partial(filename, options)
      
    # XAML Partial
    elsif File.exists? "#{path}#{filename}.#{xaml_ext}"
      return render_xaml_partial(filename, options)
    
    # Fallback to normal Rails rendering
    else
      return render_without_silverlight(options, &block)
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
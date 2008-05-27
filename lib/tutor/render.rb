module Tutor::Render
  
  TEMPLATE_PATH = "../../lib/tutor/views/"
  
  module Standard
    # This is the default render method used by the tutor. It just renders
    # requested template with the template path prepended.
    def render_tutor(options = nil, &block)
      return render_resume_tutor(options, &block) if @generating_resume_template
      options = prepare_render(options)
      render options, block
    end
  end
  
  module ForExtension
    
    # This is the render method used by the tutor. It renders whatever 
    # the tutor wanted to render to string, and then appends the rendering
    # of any plugin that are loaded.
    def render_tutor(options = nil, &block)
      return render_resume_tutor(options, &block) if @generating_resume_template
      options = prepare_render(options)
      output = render_to_string options, &block
      self.active_extensions.each do |extension|
        # render_tutor will only look at :file or :template renders;
        # :template renders with the layout, :file does not, (see render)
        extension.controller = self
        method = (options[:file] || options[:template])
        unless method.nil?
          extension.send(method.split("/").last)
          output << extension.response_body unless extension.response_body.nil?
        end
        # clear out response so it doesn't show up on next request
        extension.clear_response
      end
      render :text => output
    end
    
  end
  
  module Helpers
      
    # This render is used when in building up the template for resuming.
    def render_resume_tutor(options = nil, &block)
      options = prepare_render(options)
      @resume_template ||= ""
      @resume_template << render_to_string(options, &block)
    end
    
    # makes sure the render_tutor call can find the tutor templates
    def prepare_render(options)
      return nil unless options
      [:file, :template].each do |type|
        options[type] = "#{Tutor::Render::TEMPLATE_PATH}#{options[type]}" if options[type]
      end
      options[:use_full_path] = true
      options
    end
    
  end
  
end

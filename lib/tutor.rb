module Tutor
  
  # Call this method at the top of any file after you "require 'tutor'"
  def self.requires
#    require_dependency "extensions/module"
    require_dependency "tutor/render"
    require_dependency "tutor/resume"
    require_dependency "tutor/controller"
    require_dependency "tutor/extension"
    Tutor::Extension.require_extensions
  end
  
  # Sets the tutor up with the required methods. By default, it will load
  # the standard tutor. If the :with/:without option is specified, it is loaded
  # with the given tutor extensions.
  #
  # Usage:
  #   
  #   Tutor.enable                              # loads the tutor without extensions
  #   Tutor.enable :with => :all                # loads all extensions
  #   Tutor.enable :with => ["extension1"]      # loads only the extension1 extension
  #   Tutor.enable :without => ["extension1"]   # loads all extensions except extension1
  #   Tutor.enable :with => :none               # same as "Tutor.enable"
  #
  # You can also specify resume level here. The default is :problem but can be
  # overridden with the :resume property. The only valid values for :resume are
  # :assistment or :problem
  #
  #  Tutor.enable :resume => :assistment
  #
  def self.enable(options = {})
    include Tutor::Render::Helpers
    if (options[:with] && options[:with] != :none) || options[:without]
      include Tutor::Render::ForExtension
      include Tutor::Extension
      Tutor::Extension.extensions(options[:with])
    else
      include Tutor::Render::Standard
    end
    include Tutor::Resume
    Tutor::Resume.detail options[:resume]
    include Tutor::Controller
  end
  
  # Called when this module is mixed in
  # Enables certain methods to be called from views 
  ## def self.included(base)
  ##   base.send :helper_method, :generate_resume_template
  ## end

end

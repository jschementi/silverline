# Tutor extensions allow the tutor to be extended without modifying the tutor.
module Tutor::Extension

  # Path where plugins will be stored. Each plugin must be stored
  # in a directory inside the PLUGIN_PATH, named after the underscored
  # name of the plugin. Then each directory must have a init.rb
  # file, which does the necessary work to activate the plugin.
  EXTENSION_PATH = "vendor/tutor_extensions"
  
  def active_extensions
    @@active_extensions
  end
  
  # Makes sure the actual plugin init file is required.
  def self.require_extensions
    @@installed_extensions = []
    @@active_extensions = []
    Dir.glob(EXTENSION_PATH + "/*").each do |extension|
      if valid?(extension)
        @@installed_extensions << { :path => extension, :name => short_name(extension) }
        init_file = "#{extension}/init"
        require init_file if File.file?("#{init_file}.rb")
      end
    end
  end
  
  # Removes the path from the beginning of a plugin name.
  def self.short_name(name)
    name.split("/").last.underscore
  end
  
  # Is this plugin a valid one?
  def self.valid?(name)
    return false unless File.directory?(name) 
    init_file = "#{name}/init.rb"
    return false unless File.file?(init_file)
    true
  end
  
  # Loads the plugins which should be loaded.
  def self.extensions(options = :all)
    @@active_extensions = []
    @@installed_extensions.each do |extension|
      name = extension[:name].to_sym
      next unless include_extension?(name, options)
      extension = name.to_s.camelize.constantize.new
      @@active_extensions << extension if extension.enabled?
    end
  end
  
  def unprotected_render_to_string(options = nil, &block)
    render_to_string(options, &block)
  end
  
private

  # Given a set of options from tutor_extensions, it tells 
  # whether or not a specific extension should be included.
  def self.include_extension?(extension, options = {:all => true})
    return false if options == :none
    options == :all ||
    (options.has_key?(:only)   &&  options[:only].include?(name)) || 
    (options.has_key?(:except) && !options[:except].include?(name))
  end

public
  
  # Every Tutor Plugin should extend this class
  class Base
  
    # all actions the tutor is capable of
    # IDEA: is there a way to detect this? AKA find all the .rhtml/.rjs templates?
    def extendable_actions
      [
        :next_problem,
        :next_assistment,
        :add_hint,
        :results,
        :finish_assistment,
        :scaffolding,
        :incorrect_message,
        :notice_message,
        :assistment,
        :load_tutor
      ]
    end
    
    attr_accessor :controller
    attr_reader   :response_body, :name, :path
        
    def initialize
      @response_body = ""
      @name = self.class.to_s.underscore
      @path = "#{Tutor::Extension::EXTENSION_PATH}/#{self.class.to_s.underscore}"
    end
    
    # extend this method to include any logic about when your 
    # plugin in enabled.
    #
    # TODO: Would it be a big plus to allow this to be configured
    # from the database?
    def enabled?
      true
    end
	
    # clear out the response from the plugin
    # called after response is retrieved so that the old response 
    # doesn't interfere with the next request
    def clear_response
      @response_body = ''
    end
    
  protected
  
    # render_tutor is used in substitution for +render+ by the 
    # plugin actions. This will render to a string, also allowing
    # multiple render_tutor calls.
    def render_tutor(options = nil, &block)
      options[:file] = "../../#{@path}/views/#{options[:file]}"
      @response_body << @controller.unprotected_render_to_string(options, &block)
    end
    
  private
  
    # method_missing will catch all non-existant method calls and
    # raise a NoMethodError exception, unless the method call
    # was one of the +EXTENDABLE_ACTIONS+
    def method_missing(m)
      if extendable_actions.include?(m.to_sym)
        # method is a valid action, but nothing should be done since
        # the method isn't defined
      else
        # since we got here, the method call isn't a valid action ...
        # so raise the exception
        raise NoMethodError
      end
    end
    
  end
  
end

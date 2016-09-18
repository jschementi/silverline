require 'lib/helpers/wpf/builders'
require 'lib/helpers/wpf/patch'
require 'lib/helpers/wpf/animation'
require 'lib/patch.rb' # for Inflection

include System::Windows
include System::Windows::Controls
include System::Windows::Media

include System
include System::Windows
include System::Windows::Controls
include System::Windows::Markup
include System::Windows::Media
include System::Windows::Media::Animation
include System::Windows::Media::Imaging

module Wpf

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    # Load a XAML file on a class
    # Load self.name if we weren't given a name option. If that doesn't exist, default to "app".
    # Default to UserControl as the type option, unless given.
    def use_xaml(options = {})
      if !options.has_key?(:name) || options[:name].nil?
        name = Inflection.underscore(self.name)
        options[:name] = XAP.get_file("#{name}.xaml") ? name : "app"
      end
      options[:type] = UserControl if !options.has_key?(:type) || options[:type].nil?
      
      type = options[:type].new
      Application.load_component(type, Uri.new("#{options[:name]}.xaml", UriKind.Relative))
      Application.current.root_visual = type
    end

  end
  
  def root
    application.root_visual
  end
  
end

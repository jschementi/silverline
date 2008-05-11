require 'lib/helpers/wpf/builders'
require 'lib/helpers/wpf/patch'
require 'lib/helpers/wpf/animation'

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
=begin
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def use_xaml(options = {})
      options = {:type => UserControl, :name => "app"}.merge(options)
      type = options[:type].new
      Application.load_component(type, Uri.new("#{options[:name]}.xaml", UriKind.Relative))
      Application.current.root_visual = type
    end
    
  end
=end
  def root
    application.root_visual
  end
  
end
module Silverline::Teleport::Rendering
  
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      alias_method_chain :render, :client
      helper_method :render_to_string_with_noclient if base.kind_of? ActionController::Base
    end
  end
  
  module InstanceMethods
  
    # Makes sure there a silverlight_object on the page 
    # if we're rendering with client actions
    def render_with_client(options=nil, other = {}, &block)
      if has_client_actions?
        @already_added_silverlight_object ||= :false
        act = "#{render_to_string_with_noclient(options.merge({:layout => false}), &block)}"
        output = ""
        if @already_added_silverlight_object == :false
          output << render_to_string_with_noclient(:inline => %Q(
            <%= silverlight_object :start => 'app_teleport' %>
          ))
          @already_added_silverlight_object = :true
        end
        output << act
        render_without_client({:text => output, :layout => true}, other)
      else
        render_without_client(options, other, &block)
      end
    end
    
    def render_to_string_with_noclient(options = nil, &block)
      render_without_client(options, &block)
    ensure
      erase_render_results
      forget_variables_added_to_assigns
      reset_variables_added_to_assigns
    end
  
    private
    
      def has_client_actions?(klass = nil)
        if klass.nil?
          klass = self.respond_to?(:controller) ? self.controller.class : self.class
        end
        !klass.client_actions.blank?
      end
    
      def is_client_action?(options)
        klass, action = class_and_action_from options
        has_client_actions?(klass) && klass.client_actions.include?(action.to_sym)
      end
    
      def class_and_action_from(options)
        if options[:url].has_key?(:controller)
          type = begin 
            "#{options[:url][:controller].camelize}Controller".constantize
          rescue
            "#{"#{self.controller.controller_path.split("/")[0..-2].join("/")}/#{options[:url][:controller]}".camelize}Controller".constantize
          end
        end
          
        [
          options[:url].has_key?(:controller) ? type : self.controller.class,
          options[:url].has_key?(:action) ? options[:url][:action] : self.controller.action_name
        ]
      end
  end
end
# This is the server-side implementation which keeps track of the client 
# actions, as well as any links to client actions in the rendered action.
module Silverline::Teleport::Controller
  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      after_filter :clear_client_actions  # make sure client actions get cleared
    end
  end
  
  module ClassMethods
    # Used to mark an action as a client action
    #
    # class FooController < ApplicationController
    #   client :time
    #   def time
    #     @time = Time.now
    #   end
    # end
    #
    # In this example, the time action will be run and rendered on the client
    def client(*args)
      @client_actions ||= []
      @client_actions = @client_actions + args
    end
    attr_reader :client_actions # list of all client actions in this controller
  end
  
  # list of all the client links rendered during the current request
  attr_accessor :client_links  
  
  # Need to make sure @@client_actions is cleared after each request
  # since this class never gets reconstructed
  def clear_client_actions
    self.class.send(:instance_variable_set, :@client_actions, [])
  end
  
end

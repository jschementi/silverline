require File.dirname(__FILE__) + "/../../spec_nonrails.rb"

module Silverline
  module Essential
    module Html
    end
  end
end

module ActionView
  class Base
  end
end

describe Silverline::Essential do  
  before do
    Object.instance_eval{remove_const :FileSystemWatcher} if defined?(::FileSystemWatcher)
    ::FileSystemWatcher = mock("FileSystemWatcher", :null_object => true)
    require 'silverline/essential'
  end
  
  it "should define Xap" do
    Silverline::Essential::Xap.should_not be_nil
  end
  
  it "should use Chiron for xapping" do
    Silverline::Essential::Xap.should == :chiron
  end
  
  it "should mixin essential HTML module into ActionView's Base class" do
    ActionView::Base.included_modules.include?(Silverline::Essential::Html)
  end
  
  describe "register the generator" do
    before :each do
      Silverline::Essential.instance_eval{remove_const :Generator} if defined?(Silverline::Essential::Generator)
      @gen = Silverline::Essential::Generator = mock("Generator")
    end
    
    after :each do
      load 'silverline/essential.rb'
    end
    
    it "should happen in development mode" do
      ENV.stub!(:[]).with('RAILS_ENV').and_return('development')
      @gen.should_receive(:register)
    end
    
    it "should not happen in production mode" do
      ENV.stub!(:[]).with('RAILS_ENV').and_return('production')  
      @gen.should_not_receive(:register)
    end
  end
end
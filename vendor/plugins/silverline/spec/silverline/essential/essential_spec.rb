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
  
  it "should tell the generator to register itself" do
    Silverline::Essential.instance_eval{remove_const :Generator} if defined?(Silverline::Essential::Generator)
    gen = Silverline::Essential::Generator = mock("Generator")
    gen.should_receive(:register)
    load 'silverline/essential.rb'
  end
  
end
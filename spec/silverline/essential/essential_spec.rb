require File.dirname(__FILE__) + "/../../spec_helper.rb"

describe Silverline::Essential do  
  before :each do
    @logger = mock("Logger")
    @logger.stub!(:info)
    Object.instance_eval{remove_const :RAILS_DEFAULT_LOGGER} if defined?(::RAILS_DEFAULT_LOGGER)
    ::RAILS_DEFAULT_LOGGER = @logger
  
    Object.instance_eval{remove_const :FileSystemWatcher} if defined?(::FileSystemWatcher)
    ::FileSystemWatcher = mock("FileSystemWatcher", :null_object => true)

    Object.instance_eval{remove_const :ENV} if defined?(ENV)
    ENV = mock("ENV")
    ENV.should_receive('[]').with('RAILS_ENV').at_least(:once).and_return('development')

    # TODO: this shouldn't be necessary
    require 'silverline/essential/generator'
    Silverline::Essential::Generator.stub!(:register)

    Object.instance_eval{remove_const :FileUtils} if defined? FileUtils
    FileUtils = mock("FileUtils", :null_object => true)
    
    load 'silverline/essential.rb'
  end
  
  it "should use Chiron for xapping" do
    Silverline::Essential::Xap.should == :chiron
  end
  
  it "should mixin essential HTML module into ActionView's Base class" do
    ActionView::Base.included_modules.include?(Silverline::Essential::Html)
  end
end

describe "Registering the generator" do
  it "should happen in development mode" do
    Silverline::Essential::Generator.should_receive(:register).at_least(:once)
    Object.instance_eval{remove_const :ENV} if defined?(::ENV)
    ENV = mock("ENV")
    ENV.should_receive('[]').with('RAILS_ENV').at_least(:once).and_return('development')
    load 'silverline/essential.rb'
  end
  
  it "should not happen in production mode" do
    Silverline::Essential::Generator.should_not_receive(:register)
    ENV.should_receive('[]').with('RAILS_ENV').at_least(:once).and_return('production')  
    load 'silverline/essential.rb'
  end
end

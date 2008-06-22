require File.dirname(__FILE__) + '/../../spec_nonrails.rb'

Silverline.instance_eval{remove_const :Essential} if defined?(Silverline::Essential)
Silverline::Essential = Module.new

load 'silverline/essential/html.rb'

Object.instance_eval{remove_const :HtmlTesttHost} if defined? HtmlTesttHost
HtmlTesttHost = Class.new
HtmlTesttHost.class_eval { include Silverline::Essential::Html }

describe Silverline::Essential::Html do
    
  before(:each) do
    @html = HtmlTesttHost.new
  end
  
  it "should render a silverlight include tag" do
    @html.should_receive(:templatify).with("head.html.erb", anything)
    @html.silverlight_include_tag
  end
  
  it "should render a silverlight control" do
    @html.should_receive(:require).with('erb')
    @html.stub!(:public_xap_file).and_return "/public.xap"
    @html.stub!(:generate_init_params).and_return "debug=true"
    result = @html.silverlight_object
    result['position: absolute'].should_not be_nil
    result['<object'].should_not be_nil
    result['data="data:application/x-silverlight'].should_not be_nil
    result['type="application/x-silverlight-2-b2"'].should_not be_nil
    result['<param name="source" value="/public.xap" />'].should_not be_nil
    result['width="1" height="1"'].should_not be_nil
    result['<param name="initParams" value="debug=true" />'].should_not be_nil
  end

end

describe "Private functionality of essential HTML" do
  it "should know the HTTP_HOST"
  it "should generate initParams for Silverlight and the DLR"
  it "should know the XAP file location"
  it "should know how to put JSON in initParams"
  it "should know how to render a template"
end
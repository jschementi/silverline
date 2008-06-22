require File.dirname(__FILE__) + '/../../spec_nonrails.rb'

Silverline.instance_eval{remove_const :Essential} if defined?(Silverline::Essential)
Silverline::Essential = Module.new

load 'silverline/essential/html.rb'

Object.instance_eval{remove_const :HtmlTesttHost} if defined? HtmlTesttHost
class HtmlTesttHost
  include Silverline::Essential::Html
end

describe "Public functionality of essential HTML" do
  before(:each) do
    @html = HtmlTesttHost.new
  end
  
  it "should render a silverlight include tag" do
    @html.should_receive(:templatify).with("head.html.erb", anything)
    @html.silverlight_include_tag
  end
  
  # TODO: test more of this ...
  it "should render a silverlight control" do
    @html.should_receive(:require).with('erb')
    @html.should_receive(:templatify).with("body.html.erb", anything).and_return ""
    @html.silverlight_object
  end
end

describe "Private functionality of essential HTML" do
  before(:each) do
    @html = HtmlTesttHost.new
  end
  
  it "should know the HTTP_HOST"
  
  it "should generate initParams" do
    @html.should_receive(:http_host).and_return "baz"
    result = @html.send(:generate_init_params, {:foo => "hi", :bar => "bye", :properties => {:boom => 42}})
    result = "foo=hi, bar=bye, http_host=baz"
  end
  
  it "should know the XAP file location"
  it "should know how to put JSON in initParams"
  it "should know how to render a template"
end
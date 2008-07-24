require File.dirname(__FILE__) + '/../../spec_helper.rb'

Silverline.instance_eval{remove_const :Essential} if defined?(Silverline::Essential)
Silverline::Essential = Module.new

load 'silverline/essential/html.rb'

Object.instance_eval{remove_const :HtmlTesttHost} if defined? HtmlTesttHost
class HtmlTesttHost
  include Silverline::Essential::Html
  attr_accessor :session
end

describe "Public functionality of essential HTML" do
  before(:each) do
    @html = HtmlTesttHost.new
  end
  
  it "should render a silverlight include tag" do
    @html.should_receive(:templatify).with("head.html.erb", an_instance_of(Binding)).and_return("Head HTML")
    @html.silverlight_include_tag.should == "Head HTML"
  end
  
  # TODO: test more of this ...
  it "should render a silverlight control" do
    @html.should_receive(:templatify).with("body.html.erb", an_instance_of(Binding)).and_return("Body HTML")
    result = @html.silverlight_object
    result['Body HTML'].should_not be_nil
    result['position: absolute'].should_not be_nil
  end
end

describe "Private functionality of essential HTML" do
  before(:each) do
    @html = HtmlTesttHost.new
    @html.session = mock('Session')
    @cgi = mock('cgi')
    @request = mock('request')

    Object.instance_eval{remove_const :File} if defined?(File)
    File = mock("FileClass", :null_object => true)
    file = mock("file")
    file.stub!(:read).and_return "This is a string"
    File.stub!(:open).and_yield(file)

    Object.instance_eval{remove_const :ERB} if defined?(ERB)
    ERB = mock("ERBClass")
    @erb = mock("ERB")
  end

  it "should know the HTTP_HOST for mongrel" do
    @html.session.stub!(:cgi).and_return @cgi
    @cgi.stub!(:instance_variable_get).with(:@request).and_return(@request)
    @request.stub!(:params).and_return({"HTTP_HOST" => "http://foo.com"})

    @html.send(:http_host).should == "http://foo.com"
  end
  it "should know the HTTP_HOST for WEBrick" do
    @html.session.stub!(:cgi).and_return @cgi
    @cgi.stub!(:instance_variable_get).with(:@request).and_return(nil)
    @cgi.stub!(:env_table).and_return({"HTTP_HOST" => "http://foo.com"})

    @html.send(:http_host).should == "http://foo.com"
  end

  it "should generate initParams" do
    @html.should_receive(:http_host).and_return "baz"

    result = @html.send(:generate_init_params, {:foo => "hi", :bar => "bye", :properties => {:boom => 42}})
    result.should == "bar=bye, foo=hi, http_host=baz"
  end

  it "should know the XAP file location" do
    Silverline.should_receive(:const_get).with(:XAP_FILE).and_return "path/to/foo.xap"

    @html.send(:public_xap_file).should == "/foo.xap"
  end

  it "should know how to put JSON in initParams" do
    h = {:a => "hi", :b => "bye"}
    h.should_receive(:to_json).and_return("{'a': 'hi', 'b': 'bye'}")

    @html.send(:jsonify, h).should == "{'a': 'hi'==> 'b': 'bye'}"
  end

  it "should know how to render a template" do
    File.should_receive(:open).with("#{RAILS_ROOT}/vendor/plugins/silverline/templates/body.html.erb").and_return "I'm the file contents"
    ERB.should_receive(:new).with("I'm the file contents").and_return @erb
    @erb.should_receive(:result).with(an_instance_of(Binding)).and_return("I'm the template string!")

    @html.send(:templatify, "body.html.erb", @html.send(:binding)).should == "I'm the template string!"
  end
end

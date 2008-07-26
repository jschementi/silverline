require File.dirname(__FILE__) + '/../../spec_helper.rb'

Silverline::Essential.instance_eval{remove_const :XAP} if defined?(Silverline::Essential::XAP)

def define_xap
  Silverline::Essential.instance_eval{remove_const :Xap} if defined?(Silverline::Essential::Xap)
end

def prepare_xap(platform = nil)
  define_xap
  yield
  load 'silverline/essential/xap.rb'
  @xap = Silverline::Essential::XAP.new("foo", "Bar")
  @chr = "public/ironruby/Chiron.exe /s /d:Bar /z:foo" unless platform.nil?
end

describe "XAPBase" do
  
  it "should initialize itself with a file to XAP to and a directory to XAP" do
    Silverline::Essential::Xap = :chiron
    load 'silverline/essential/xap.rb'
    xapbase = Silverline::Essential::XAPBase.new("foo", "Bar")
    xapbase.instance_variable_get(:@file) == "foo"
    xapbase.instance_variable_get(:@files) == []
    xapbase.instance_variable_get(:@directory) == "Bar"
  end
  
end

describe "Chiron XAP on Windows" do
  
  it "should generate the XAP" do
    prepare_xap(:windows) { Silverline::Essential::Xap = :chiron }
    @xap.should_receive(:system).with("mono #{@chr}").and_return false
    @xap.should_receive(:system).with(@chr).and_return true
    
    @xap.generate
  end
  
end

describe "Chiron XAP on Mono" do
  
  it "should generate the XAP" do
    prepare_xap(:mono) { Silverline::Essential::Xap = :chiron }
    
    @xap.should_receive(:system).with("mono #{@chr}").and_return true
    @xap.should_not_receive(:system).with(@chr)
    
    @xap.generate
  end
  
end

=begin
describe "Ruby XAP" do

  it "should generate the XAP" do
    #prepare_xap { Silverline::Essential::Xap = :rubyzip }
    pending
  end
  
  it "should generate the AppManifest" do
    pending
  end
  
end
=end

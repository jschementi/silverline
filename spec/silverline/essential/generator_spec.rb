require File.dirname(__FILE__) + '/../../spec_helper.rb'

Silverline::Essential.instance_eval{remove_const :Xap} if defined?(Silverline::Essential::Xap)
Silverline::Essential::Xap = :chiron

load 'silverline/essential/generator.rb'

describe Silverline::Essential::Generator do
  
  before do
    Silverline::Essential.instance_eval{remove_const :Generator} if defined?(Silverline::Essential::Generator)
    Silverline::Essential::Generator = Module.new
  end
  
  before(:each) do
    @logger = mock("Logger")
    @logger.stub!(:info)
    Object.instance_eval{remove_const :RAILS_DEFAULT_LOGGER} if defined?(::RAILS_DEFAULT_LOGGER)
    ::RAILS_DEFAULT_LOGGER = @logger

    load 'silverline/essential/generator.rb'
  
    Object.instance_eval{ remove_const :FileUtils} if defined?(FileUtils)
    Object.instance_eval{ remove_const :File} if defined?(File)
    
    @watcher = mock("FileSystemWatcher")
    FileSystemWatcher.stub!(:new).and_return @watcher
    
    @gen = Silverline::Essential::Generator

    Silverline::Essential.instance_eval{ remove_const :XAP } if defined?(Silverline::Essential::XAP)
    Silverline::Essential::XAP = mock("XAP")
    @xap = Silverline::Essential::XAP
    xap_instance = mock("XAPInstance")
    @xap.stub!(:new).and_return xap_instance
    xap_instance.stub!(:generate)
  end
  
  it "should watch directories to put into XAP" do
    @gen.should_receive(:create_directories)

    @watcher.should_receive(:addDirectory).with(Silverline::CLIENT_ROOT)
    @watcher.should_receive(:addDirectory).with(Silverline::PLUGIN_CLIENT)
    
    # TODO: should the visualize/teleport stuff deal with defining what to watch?
    #@watcher.should_receive(:addDirectory).with(Silverline::RAILS_CTRLRS)
    @watcher.stub!(:addFile)
    @watcher.should_receive(:addDirectory).with(Silverline::RAILS_VIEWS)
    
    @watcher.should_receive(:sleepTime=).with(1)
    
    @watcher.should_receive(:start)
    
    @gen.should_receive(:generate)
    
    @gen.register
  end

  it "should create required directories" do
    FileUtils = mock("FileUtils")
    FileUtils.should_receive(:mkdir_p).with(Silverline::TMP_CLIENT)
    FileUtils.should_receive(:mkdir_p).with(Silverline::CLIENT_ROOT)
    @gen.create_directories
  end

  it "should delete the XAP" do
    File = mock("File")
    FileUtils = mock("FileUtils", :null_object => true)
    File.stub!(:exists?).with(Silverline::XAP_FILE).and_return true
    File.should_receive(:delete).with(Silverline::XAP_FILE).ordered
    @gen.generate
  end
  
  it "should not try to delete the XAP" do
    File = mock("File")
    FileUtils = mock("FileUtils", :null_object => true)
    File.stub!(:exists?).with(Silverline::XAP_FILE).and_return false
    File.should_not_receive(:delete).with(Silverline::XAP_FILE)
    @gen.generate
  end
   
  it "should generate the XAP from the watched folders" do
    @xap = mock("XAP")
    File = mock("File", :null_object => true)
    FileUtils = mock("FileUtils")    
    
    logger.should_receive(:info).with("Silverline: Generating client.xap")
    
    FileUtils.should_receive(:cp_r).with("#{Silverline::PLUGIN_CLIENT}/.", Silverline::TMP_CLIENT).ordered
    
    # TODO: should Visualize/Essential be defining these folders to watch
    FileUtils.should_receive(:mkdir_p).with("#{Silverline::TMP_CLIENT}/controllers").ordered
    FileUtils.should_receive(:mkdir_p).with("#{Silverline::TMP_CLIENT}/views").ordered
    FileUtils.should_receive(:cp).with('app/controllers/client_controller.rb', "#{Silverline::TMP_CLIENT}/controllers").ordered
    FileUtils.should_receive(:cp_r).with("#{Silverline::RAILS_VIEWS}/.", "#{Silverline::TMP_CLIENT}/views").ordered
    
    FileUtils.should_receive(:cp_r).with("#{Silverline::CLIENT_ROOT}/.", Silverline::TMP_CLIENT).ordered
    
    Silverline::Essential::XAP.should_receive(:new).with(Silverline::XAP_FILE, Silverline::TMP_CLIENT).and_return @xap
    @xap.should_receive(:generate)
    
    FileUtils.should_receive(:rm_r).with(Silverline::TMP_CLIENT).ordered
    
    @gen.generate
  end
  
end

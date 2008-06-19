require File.dirname(__FILE__) + '/../spec_helper.rb'
require File.dirname(__FILE__) + '/../../lib/silverline.rb'

def require(path)
  $required = path
end

describe Silverline do
  it "should define path to Rails views" do
    Silverline::RAILS_VIEWS.should be_relative_to("app/views")
  end

  it "should define path to XAP file" do
    Silverline::XAP_FILE.should be_relative_to("public/client.xap")
  end

  it "should define path to client root" do
    Silverline::CLIENT_ROOT.should be_relative_to("lib/client")
  end

  it "should define path to client temp folder" do
    Silverline::TMP_CLIENT.should be_relative_to("tmp/client")
  end

  it "should define path to Silverline plugin root" do
    Silverline::PLUGIN_ROOT.should be_relative_to("vendor/plugins/silverline")
  end

  it "should define path to plugin client folder" do
    Silverline::PLUGIN_CLIENT.should be_relative_to("vendor/plugins/silverline/client")
  end

  describe FileExtensions do
    it "should define WPF" do
      FileExtensions::WPF.should == "wpf.rb"
    end

    it "should define ERb XAML" do
      FileExtensions::XAML_ERB.should == "xaml.erb"
    end

    it "should define XAML" do 
      FileExtensions::XAML.should == "xaml"
    end

    it "should define Ruby" do 
      FileExtensions.RB.should == "rb"
    end
  end
  
  it "should require essential" do
    $required.should == "silverline/essential"
  end
  it "should require visualize" do
    $required.should == "silverline/visualize"
  end
  it "should require teleport" do
    $required.should == "silverline/teleport"
  end

end


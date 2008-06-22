require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Silverline do
  it "should define path to Rails views" do
    Silverline::RAILS_VIEWS.should be_relative_to("app/views")
  end
  it "should define path to Rails Controllers" do
    Silverline::RAILS_CTRLRS.should be_relative_to("app/controllers")
  end
  it "should define path to Rails Models" do
    Silverline::RAILS_MODELS.should be_relative_to("app/models")
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

  describe Silverline::FileExtensions do
    
    it "should define WPF" do
      Silverline::FileExtensions::WPF.should == "wpf.rb"
    end

    it "should define ERb XAML" do
      Silverline::FileExtensions::XAML_ERB.should == "xaml.erb"
    end

    it "should define XAML" do 
      Silverline::FileExtensions::XAML.should == "xaml"
    end

    it "should define Ruby" do 
      Silverline::FileExtensions::RB.should == "rb"
    end
  end

end


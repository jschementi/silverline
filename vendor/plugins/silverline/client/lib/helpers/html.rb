require 'lib/helpers/html/patch'
include System::Windows::Browser

module Html
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def document
      HtmlPage.document
    end
  end
  
  def document
    self.class.document
  end
end
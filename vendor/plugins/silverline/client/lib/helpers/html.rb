require 'lib/helpers/html/patch'
include System::Windows::Browser

module Html
=begin
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def document
      HtmlPage.document
    end
  end
=end  
  def document
    self.class.document
  end
end
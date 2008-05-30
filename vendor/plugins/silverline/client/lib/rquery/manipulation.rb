module RQuery
  
  module Manipulation
  
    module ChangingContents
      def html
        self.get_property(:innerHTML)
      end
      def html=(value)
        self.set_property(:innerHTML, value)
        self
      end
    end
  
    module InsertingInside
      def append(content)
        self.html = "#{self.html}#{content}"
        self
      end
      def prepend(content)
        self.html = "#{content}#{self.html}"
        self
      end
    end
  
    module InsertingOutside
      # TODO
    end
  
    module InsertingAround
      # TODO
    end
  
    module Replacing
      # TODO
    end
  
    module Removing
      # TODO
    end
  
    module Copying
      # TODO
    end
  
  end
  
end

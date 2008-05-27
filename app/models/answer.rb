# An Answer represents a correct or incorrect answer against which the student's
#  answer will be evaluated. Sometimes these answers can be selected from explicity,
#  as from a set of radio buttons.
class Answer < ActiveRecord::Base
  acts_as_list :scope => :problem
  
  belongs_to :problem
  
  def correct?() 
    is_correct 
  end
end

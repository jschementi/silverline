# A Hint represents a textual form of help, guiding the student to a problem's solution
class Hint < ActiveRecord::Base
  acts_as_list :scope => :problem
  
  belongs_to :problem
  
  has_many :action_hints
end

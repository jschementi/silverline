# A scaffold holds a set of "scaffold" sub-problems 
class Scaffold < ActiveRecord::Base
  
  belongs_to :problem
  has_many :problems, :order => "position", :dependent => :destroy
  
  after_create :generate_name_and_enable
  after_create :generate_problem
  
private

  # Sets a standard name for the scaffold and enables it.
  def generate_name_and_enable
    self.name = "Scaffold ##{self.id}"
    self.enabled = true
    true
  end

  # Ensures that the new scaffold has a problem in it when it is created
  def generate_problem
    self.problems.create :assistment_id => self.problem.assistment.id
  end
      
end

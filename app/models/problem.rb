# A problem represents a single question/challenge along with its answers 
# and any pre-defined assistance such as hints, "scaffolding", etc.
# ===
# A problem can be either the main problem -- the top-level problem that
#  defines the starting point of an assistment -- or a scaffold problem
class Problem < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper
  
  acts_as_list :scope => :scaffold

  # accessor for the incorrect message; used by problem_type#correct?
  attr_accessor :incorrect_message

  has_one :scaffold, :dependent => :destroy

  has_many :hints, :order => "position", :dependent => :destroy
  has_many :answers, :order => "position", :dependent => :destroy
  
  belongs_to :assistment
  belongs_to :problem_type
  
  before_create :initialize_problem_type
  
  DEFAULT_PROBLEM_TYPE = "choose_1"
  
  # Get this problem's name
  # If it is a main problem, "Main Problem" will be returned
  # Otherwise, if a name has been saved for this problem, that
  #  is the name
  # Otherwise, if the problem has a body, a truncated form of that
  #  body will be returned
  # Otherwise, "Scaffold" will be returned
  def name
    return "Main Problem" if main? 
    return self[:name] unless self[:name].blank?
    return truncate(strip_tags(body), 20) unless body.blank?
    "Scaffold"
  end
  
  # Get whether the given answer is correct for the specified problem.
  # The answer must be in a certain form according to the problem type,
  #  check ProblemType#correct? for an explanation.
  def correct?(answer)
    problem_type.correct?(self, answer)
  end
  
  # Returns all correct answers for this problem
  def correct_answers
    answers.select { |answer| answer.correct? }
  end
  
  # Does this problem have scaffolding problems?
  def has_scaffolds?
    (!(scaffold.nil?)) and scaffold.enabled
  end
  
  # Return the scaffold set of which this problem is part
  def parent_scaffold
    Scaffold.find_by_id(scaffold_id)
  end
  
  # Is this problem a scaffolding problem?
  def is_part_of_scaffold?
    not scaffold_id.nil?
  end
  
  # Is this problem the main problem for its assistment?
  def main?
    scaffold_id.nil?
  end
  
  # Returns the next problem
  def next
    self.lower_item if self.is_part_of_scaffold?
  end
  
  # Returns number of levels of scaffolding deep the problem is
  def depth
    return 0 if main? 
    return 1 + Scaffold.find_by_id(scaffold_id).problem.depth
  end

  # return the most commom wrong answer and its percentage rate in a class
  def common_wrong_in_class student_class
    assignment_answers = AssignmentAnswer.find_all_by_problem_id_and_correct(self.id, false)
    return nil, nil if assignment_answers.size==0
    #class filter
    assignment_answers = assignment_answers.find_all {
                            |x| !x.user.student.classes.detect {|y| y==student_class and x.first_response?}.nil? }
    common_wrong_answer assignment_answers
  end

  # return the most commom wrong answer and its percentage rate in a school
  def common_wrong_in_school school
    assignment_answers = AssignmentAnswer.find_all_by_problem_id_and_correct(self.id, false)
    return nil, nil if assignment_answers.size==0
    # school filter
    assignment_answers = assignment_answers.find_all {|x| x.user.student.school==school and x.first_response?}
    common_wrong_answer assignment_answers
  end

  # return the most commom wrong answer and its percentage rate in a district
  def common_wrong_in_district district
    assignment_answers = AssignmentAnswer.find_all_by_problem_id_and_correct(self.id, false)
    return nil, nil if assignment_answers.size==0
    # district filter
    assignment_answers = assignment_answers.find_all {|x| x.user.student.school.district==district and x.first_response?}
    common_wrong_answer assignment_answers
  end

private

  def common_wrong_answer assignment_answers
    return nil, nil if assignment_answers.size==0
    most_commmon_answers = assignment_answers.sort_by{
                            |x| assignment_answers.find_all{|y| y.answer == x.answer}.size}.reverse
    return nil, nil if most_commmon_answers.size==0
    return most_commmon_answers[0].answer, 
           assignment_answers.find_all{|y| y.answer == most_commmon_answers[0].answer}.size*100/assignment_answers.size     
  end

  # Initializes this problem's type to be the default type if it has not
  #  yet been set when it is being saved
  def initialize_problem_type
    self.problem_type ||= ProblemType.find_by_name(DEFAULT_PROBLEM_TYPE)
    true
  end

end

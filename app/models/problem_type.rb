# A ProblemType defines the way an answer is evaluated for correctness 
class ProblemType < ActiveRecord::Base
  include Tutor::AlgebraInterpreter
  
  has_many :problems
  
  # Returns description of problem type, but if the description is
  # not set it transforms the problem type name into a readable description
  def description
    if read_attribute(:description).nil?
      name.split("_").join(" ").capitalize
    else
      read_attribute(:description)
    end
  end
  
  # Checks if a answer is correct for the given problem. Delegates 
  # the check to the specific problem type correct method.
  # Also sets problem.incorrect_message to be the incorrect message(s) of
  # the wrong answer(s).
  #
  # * problem (Problem): the problem being answered
  # * answer (Hash): the answer being checked
  def correct?(problem, answer)
    send(name.underscore + "_correct?", problem, answer)
  end

private

  # Tells if a answer is correct or not for a choose 1
  # problem, based on just the text answer.
  #
  # Returns true if the answer is correct, false otherwise.
  # problem.incorrect_message: the incorrect message or the chosen answer, nil if
  # the answer doesn't have one
  #
  # * problem: the problem being answered
  # * answer: the answer being checked
  def choose_1_correct?(problem, answer)
    answer = Answer.find_by_problem_id_and_id(problem.id, answer[:id])
    correct = answer && answer.correct?
    problem.incorrect_message = answer.incorrect_message unless correct
    correct
  end
  
  # Tells if an collection of answers is correct or not for a 
  # choose n problem, where the answer_value is an array of 
  # answer values. All individual answers have to be correct 
  # for the problem to be correct. If not all answers are correct, 
  # returns the number of correct answers, and false if no answers
  # are correct
  #
  # Returns true if all answers are correct, and false if just one
  # of the answers is incorrect.
  # problem.incorrect_message: to_sentence of all the incorrect_messages for
  # the incorrect answers, nil if none of them had incorrect answers
  #
  # * problem (Problem): the problem being answered
  # * answers (Hash): :answer_id => selected?
  def choose_n_correct?(problem, answers)
    incorrect_count = 0
    incorrect_message = []
    answers.each do |answer_id, selected|
      answer_id, selected = answer_id.to_i, selected.to_i == 1
      answer = Answer.find_by_id(answer_id)
      unless selected == answer.correct?
        incorrect_count += 1 
        incorrect_message << answer.incorrect_message if answer.incorrect_message?
      end
    end
    correct = (incorrect_count == 0)
    problem.incorrect_message = incorrect_message.to_sentence unless correct
    correct
  end
  
  # Tells if an ranking of answers is correct or not for a rank
  # problem, where answer_value is an array of answer ids,
  # in order of the ranking.
  #
  # Return true if ranking is correct, false otherwise.
  # problem.incorrect_message is always nil
  #
  # * problem (Problem): the problem being answered
  # * answers (Hash): answer_id => position
  def rank_correct?(problem, answers)
    problem.incorrect_message = nil
    answers.each do |id, position|
      answer = Answer.find(id)
      return false if (answer.position.to_i) != position.to_i
    end
    return true
  end

  # Tells if an answer is correct or not for a fill in problem,
  # where answer_value is the exact text of the answer.
  #
  # Returns true if answer is correct, false otherwise.
  # problem.incorrect_message = incorrect message if the answer has one, nil otherwise
  #
  # * problem (Problem): the problem being answered
  # * answer (Hash): :body => answer.value
  def fill_in_1_correct?(problem, answer)
    # Before sending the answer to the query mechanism, strip out any spaces
    # before and after the actual text
    answer = Answer.find_by_problem_id_and_value(problem.id, answer[:body].strip)
    correct = answer && answer.correct?
    problem.incorrect_message = answer.incorrect_message unless correct || answer.nil?
    correct
  end
  
  # Tells if an answer is correct or not for a algebra problem,
  # where answer_value is a string representing a mathematical
  # expression. To be correct, answer_value must be mathematically 
  # equivalient to the correct answer.
  #
  # Returns true if answer is mathematically equivalent, false otherwise.
  # problem.incorrect_message is always nil
  #
  # * problem (Problem): the problem being answered
  # * answer (Hash): :body => mathematical expression to be check for equivalence
  #   with the problem's answer
  def algebra_correct?(problem, answer)
    problem.incorrect_message = nil

    # answer_value is incorrect if there are no correct answers for the problem
    correct_answers = problem.correct_answers
    return false if correct_answers.empty?
    
    # answer_value is correct if there is one equivalent answer
    correct_answers.each do |correct_answer|
      correct = expressions_eq?(answer[:body], correct_answer.value)
      return true if correct
    end

    # no equavalent correct answers, so answer_value is incorrect
    return false
  end

end

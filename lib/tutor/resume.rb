# This module contains logic to Resume the Tutor at the Assistment and Problem level.
# To choose the level, set RESUME_DETAIL to either :assistment or :problem before
# resume_tutor is called
#
module Tutor::Resume

public

  def self.detail(option = nil)
    # always default to assistment-level resuming
    # TODO: change this to use the above option!
    @@resume_detail = :assistment
  end

protected

  # Resumes the tutor
  #
  # params:
  # * :problem_id = main problem of the assistment being loaded
  # * :class_assignment_id = current assignment (optional)
  #
  # effects:
  # * params[:problem_id] = the problem we are resuming to
  # * @resume_template = javascript to resume to tutor
  #
  def resume_tutor
    @resume_template = ""
    @class_assignment = ClassAssignment.find(params[:class_assignment_id], :include => :sequence) if params[:class_assignment_id]
    resume_to_detail unless @class_assignment.nil? # resuming only matters for assignments
  end

private

  # When @@resume_detail === :assistment
  #   Finds all the action_problems for this Assistment and deletes them and their children.
  #   This resumes the student ONLY at the Assistment level.
  #
  # When @@resume_detail === :problem
  #   This builds up "student_actions" and generates a resume template from them
  # 
  #   For the tutor to react in any way, the student must explicitly perform an action,
  #   be it either answering a problem or asking for help. The tutor resumes Students based
  #   on this assumption, and does so by looking at assignment_answers and action_hints;
  #   the actions which are explicit.
  # 
  # instance variables:
  # * @class_assignment = the current assignment
  # * @assistment = the current assistment
  #
  # effects (When @@resume_detail === :problem):
  # * @resume_template = javascript to resume to tutor
  #
  def resume_to_detail
    @assistment = Problem.find(params[:problem_id], :include => :assistment).assistment
    
    logger.info "Start Problem(#{params[:problem_id]})"
    
    # find all the action_problems for this Assistment
    action = Action.find_by_user_id_and_class_assignment_id(
      current_user.id, @class_assignment.id,
      :include => {:action_problems => [
        {:problem => :assistment}, 
        {:action_hints => {:action_problem => :problem}}, 
        {:assignment_answers => {:problem => :assistment}}
      ]})
    action_problems = action.action_problems.select{ |ap| ap.problem.assistment == @assistment }
    
    reset_hints
    
    case @@resume_detail
    when :problem
      
      # figure out which problem we will be resuming the assistment to
      params[:problem_id] = @assistment.current_problem(@class_assignment, current_user).id
      logger.info "Resume to Problem(#{params[:problem_id]})"
      
      # get the hints and answers for this problem
      hints = action_problems.collect{ |ap| ap.action_hints }.flatten
      answers = action_problems.collect{ |ap| ap.assignment_answers }.flatten

      # combine the answers and hints, sort by time, and throw away
      # anything outside the action time window.
      student_actions = (answers + hints).sort_by(&:time)

      generate_resume_template

    when :assistment
      
      # Delete all action problems for this assistment, restore the :problem_id param,
      # register our action observer, and notify the observer again that we are beginning this problem.
      # This allows the student to resume at the assistment level and avoids resuming.
      action_problems.each {|ap| ap.destroy}
      action.action_problems.find_all_by_end_time(nil).each{|ap| ap.destroy} # sanity check, make sure there are no action_problem still yet to be finished
      enable_action_history
      changed_and_notify_observers :begin_problem => @assistment.problem

    end
  end

  # Returns a javascript string to retart an assistment.
  #
  # * @class_assignment = the current assignment
  #
  def generate_resume_template(student_actions)
    logger.info "#Generating Resume Template ... #{student_actions.size} total student actions to resume\n------------------------------"
    
    @generating_resume_template = true
    
    # backup params 
    orig_params = {
      :problem_id           => params[:problem_id],
      :class_assignment_id  => params[:class_assignment_id]
    }

    student_actions.each do |a|

      params[:sequence_id]    = @class_assignment.sequence.id  # always pass the sequence id
      if a.kind_of?(AssignmentAnswer) && !a.answer.nil?
        # They pressed the submit answer button
        params[:id]           = a.problem.id
        params[:answer]       = a.answer
        params[:action]       = "process_answer"
        logger.info ":id => #{params[:id]} , :answer => #{params[:answer]}, :action => {params[:action]}"
      else
        # They pressed the request help button
        problem = a.kind_of?(ActionHint) ? a.action_problem.problem : a.problem
        params[:action]       = "request_help"
        params[:problem_id]   = problem.id
        logger.info ":problem_id => #{params[:problem_id]} , :action => #{params[:action]}"
      end
      send params[:action]

    end
    
    # restore params
    params[:problem_id]           = orig_params[:problem_id]
    params[:class_assignment_id]  = orig_params[:class_assignment_id]

    @generating_resume_template = false
    
    logger.info "Done resuming\n------------------------------"
  end


end

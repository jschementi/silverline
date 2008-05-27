require "observer"

# Module defining how the Tutor should behave. render_tutor must be defined before
# including this file (either Tutor::Render or Tutor::RenderForPlugins)
#
module Tutor::Controller

public

  def current_user
    :false
  end

  # Allow observers to listen for Actions
  include Observable

  # Process the answer text specified by the param 'answer.text' for the
  # specified problem
  #
  # params
  # * :id = the id of the Problem
  # * :sequence_id = the id of the Sequence the problem is in
  # * :answer = student answer, expected to be formatted:
  #             choose_1: hash, :body => answer.body
  #             choose_n: hash, for each answer: answer.id => (0|1) (1 is selected, 0 is unselected)
  #             rank:     hash, for each answer: answer.id => position
  #             fill_in:  hash, :body => answer.body
  #             algebra:  hash, :body => answer.body (algebra equivalent)
  #
  def process_answer
    @problem = Problem.find(params[:id])
    unless params[:answer]
      @message = "You did not submit an answer; please make sure to select/type an answer."
      render_tutor :file => "notice_message"
    else
      ActiveRecord::Base.transaction do
        if (@problem.correct?(params[:answer]))  # answer is correct
          changed_and_notify_observers(:answer => { :correct => params[:answer], :problem => @problem})
          flash[:message] = "Correct!"
          flash[:message_type] = :correct
          move_student_on
        else  # answer is incorrect!
          changed_and_notify_observers(:answer => { :incorrect => params[:answer], :problem => @problem})
          flash[:message] = "Sorry, that is incorrect. Let's move on and figure out why!"
          flash[:message_type] = :incorrect
          help_student_out
        end
      end
    end
  end

  # If a student requests help on a problem that has scaffolds,
  # push them into the scaffold, otherwise get the next hint for
  # the problem specified by the param 'problem_id'.
  # session['hint_cout'] is the number of hints shown so far, and
  # renders the hint
  #
  # params
  # * :problem_id = the id of the problem to get the next hint of
  #
  def request_help
    @problem = Problem.find params[:problem_id], :include => :hints, :order => "hints.position"
    @hints = @problem.hints
    if @problem.has_scaffolds?
      ActiveRecord::Base.transaction do
        changed_and_notify_observers(:answer => { :incorrect => nil, :problem => @problem})
        flash[:message] = "Let's move on and figure out this problem"
        flash[:message_type] = :neutral
        help_student_out
      end
    else
      logger.info "hint_count = #{session[:hint_count]}; total hints count = #{@hints.size}"
      if (session[:hint_count] + 1) < @hints.size
        session[:hint_count] += 1
        logger.info "hint_count incremeneted: #{session[:hint_count]}"
        @hint = @hints[session[:hint_count]]
        ActiveRecord::Base.transaction do
          changed_and_notify_observers(:hint => @hint)
        end
        render_tutor :file => "add_hint"
      else
        # TODO: make this message to be a hint_notice_message
        @message = "Sorry, the number of requested hints has exceeded the number of actual hints! Please let us know about this by commenting."
        render_tutor :file => "notice_message"
      end
    end
  end

  # Manually move student into the next assistment
  #
  # params
  # * :section_id = section the assistment is in
  # * :id = id of the assistment
  #
  def next_assistment
    reset_hints
    @sequence = Sequence.find(params[:sequence_id])
    @main_problem = Assistment.find(params[:id], :include => :problems).problem
    ActiveRecord::Base.transaction do
      changed_and_notify_observers(:begin_problem => @main_problem)
    end
    render_tutor :file => "next_assistment"
  end

  # When the tutor page loads it makes an ajax request for onload.
  # This is a hook for resuming and tutor extensions
  #
  # params
  # * :problem_id = problem of the assistment being loaded
  #
  def load_tutor
    ActiveRecord::Base.transaction do
      resume_tutor
    end
    render_tutor :file => "load_tutor"
  end

private

  # Displays the next problem, or a finished screen
  # Note: only should be called from process_answer, so keep private
  #
  # * @problem = problem that we are moving from
  # * @section = the section that the problem is in
  #
  def move_student_on
    changed_and_notify_observers(:end_problem => @problem)
    reset_hints
    @sequence = Sequence.find params[:sequence_id] unless params[:sequence_id].nil?

    @next_problem = @problem.next

    if @next_problem.nil?
      # We don't have a next problem, so fetch the next Assistment

      if @sequence.nil?
        # We were actually previewing an Assistment, so finish the assistment
        # (but don't show a next assistment link)
        @next_assistment = nil
        render_tutor :file => "finish_assistment"
      else

        # Complete this Assistment
        @sequence.completeAssistment(session[:assignment_id], current_user)

        # Move on to next Assistment
        @next_up = @sequence.next_assistment(session[:assignment_id], current_user)
        @next_assistment = unless @next_up.nil? then Assistment.find_by_id(@next_up.first) end

        if @next_assistment.nil?
          # No Assistment, so we are done with sequence! Congratulate and show results.
          @assignment = ClassAssignment.find_by_id(session[:assignment_id])
          changed_and_notify_observers(:end_assignment => nil)
          render_tutor :file => "results"
        else
          # Prompt to move to next assistment
          render_tutor :file => "finish_assistment"
        end

      end

    else
      # Go to the next problem
      changed_and_notify_observers(:begin_problem => @next_problem)
      render_tutor :file => "next_problem"
    end
  end

  # Shows the student help, be it scaffolding or incorrect messages or hints
  # Note: only should be called from process_answer, so keep private
  #
  # * @problem = problem that we are moving from
  #
  def help_student_out

    if @problem.has_scaffolds?

      # the problem has scaffolds, so push the user into the first scaffolding problem
      reset_hints
      @sequence = Sequence.find params[:sequence_id] unless params[:sequence_id].nil?
      @parent = @problem
      @problem = @parent.scaffold.problems.first
      changed_and_notify_observers(:end_problem => @parent)
      changed_and_notify_observers(:begin_problem => @problem)
      render_tutor :file => "scaffolding"

    else

      # there are no scaffolds, so show a incorrect message
      msg = @problem.incorrect_message # set in ProblemType#correct?
      @incorrect_message = (msg.blank?) ? next_default_message : msg
      render_tutor :file => "incorrect_message"

    end
  end

  # Begin the assignment
  #
  # * class_assignment = the assignment to begin
  #
  def begin_assignment(class_assignment)
    start_assignment(class_assignment)
    ActiveRecord::Base.transaction do
      changed_and_notify_observers(:begin_assignment => @class_assignment)
      begin_sequence(@class_assignment.sequence)
    end
  end

  # Resume the assignment; does not notify of the begin here!
  #
  # * class_assignment = the assignment to resume
  #
  def resume_assignment(class_assignment)
    start_assignment(class_assignment)
    ActiveRecord::Base.transaction do
      begin_sequence(@class_assignment.sequence)
    end
  end

  # Starts an assignment
  #
  # * class_assignment = the assignment to start
  #
  def start_assignment(class_assignment)
    @class_assignment = class_assignment
    session[:assignment_id] = @class_assignment.id
  end

  # Begin the sequence
  #
  # * sequence = the sequence to begin
  #
  def begin_sequence(sequence)
    @sequence = sequence
    session[:assignment_id] = nil if @class_assignment.nil?

    # Find the next Assistment (gives us the current on if we're not done with it)
    @next_up = @sequence.next_assistment(session[:assignment_id], current_user)

    # Begin the assistment if we found it, otherwise end the assignment.
    unless @next_up.nil?
      @assistment = Assistment.find(@next_up.first)
      begin_assistment(@assistment)
    else
      changed_and_notify_observers(:end_assignment => @class_assignment)
      render_tutor :template => "complete"
    end
  end

  # Begin the assistment
  #
  # * assistment = the assistment to begin
  #
  def begin_assistment(assistment)
    @main_problem = assistment.problem
    reset_hints
    changed_and_notify_observers(:begin_problem => @main_problem)
    render_tutor :template => "assistment"
  end

  # If this user has a progress for this sequence with a nil assignment, remove it.
  # Note: This means any type of resuming will not be available when previewing
  #       sequences. You will observe that especially in a Random*Section, where
  #       you refresh the preview and keep getting a new first problem.
  #
  # Arguments:
  # * sequence: sequence to initialize for preview
  #
  def initialize_preview(sequence)
    progress = sequence.progress(nil, current_user)
    progress.destroy unless progress.nil?
  end

  # Indicates that the observed state has changed and notifies all
  # observers of the change (which calls the observer's update method)
  #
  # Instance Variables:
  # * @generating_resume_template: boolean indicating whether we are currently
  #   generating a resume template
  #
  # Arguments: 
  # * data: any data that you want to be avaliable to an observer.
  #
  def changed_and_notify_observers(data)
    unless @generating_resume_template
      changed
      notify_observers([data, session, current_user])
    end
  end

  # Return a random incorrect message
  #
  DEFAULT_INCORRECT_MESSAGES = ["No, sorry", "No, try again", "That is not correct, try again."]
  def next_default_message
    DEFAULT_INCORRECT_MESSAGES[rand(DEFAULT_INCORRECT_MESSAGES.size)]
  end

  # Reset the hint counter to indicate that no hints are currently shown.
  # 
  # effects:
  # * session[:hint_count] is -1
  def reset_hints
    logger.info "hint_count = #{session[:hint_count]}, resetting to -1"
    session[:hint_count] = -1
    logger.info "hint_count = #{session[:hint_count]}"
  end

end

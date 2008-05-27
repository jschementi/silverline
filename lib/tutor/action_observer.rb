module Tutor

  class ActionObserver
    
    # ability to access the recorder and get the current action*
    attr_reader :recorder
    
    # This is what the data looks like:
    # data = [{:method_name => the_data_to_be_recorded}, session, current_user]
    # the_data_to_be_recorded must be in a format as specified by the +ActionRecorder+ class
    def update(data)
      data_hash, session, current_user = data
      method_name = data_hash.keys.first
      @data = data_hash[method_name]
      @recorder = ActionRecorder.new(session, current_user)
      @recorder.send(method_name, @data)
    end
  
  protected 
  
    # Handles actually storing the actions of the student
    class ActionRecorder
      attr_reader :action, :action_problem, :action_hint, :assignment_answer
  
      def initialize(session, current_user)
        @session = session
        @current_user = current_user
      end
  
      # records the beginning of an assignment; aka when a student starts a root problem set. 
      # The :end_time is not set here to indicate that it is in progress. 
      def begin_assignment(assignment)
        @session[:assignment_id] = assignment.id
        @action = assignment.actions.find_by_user_id(@current_user)
        if @action.nil?
          @action = assignment.actions.create(
            :start_time => Time.now,
            :user_id    => @current_user.id)
        end
        sa = StudentAssignment.find_or_create_by_student_id_and_class_assignment_id(@current_user.student.id, assignment.id)
        sa.update_attribute :status, 1
      end
  
      # records the end of an assignment; this just updates the :end_time on the 
      # record inserted by +begin_assignment+
      def end_assignment(placeholder)
        assignment_id = @session[:assignment_id]
        @action = Action.find_by_class_assignment_id_and_user_id(
          assignment_id, @current_user.id)
        @action.update_attributes(:end_time => Time.now)
        @session[:assignment_id] = nil
        sa = StudentAssignment.find_or_create_by_student_id_and_class_assignment_id(@current_user.student.id, assignment_id)
        sa.update_attribute :status, 2
      end
  
      # Records the beginning of each problem, and adds the record to the assignment log.
      # Does not set the :end_time to indicate this is in progress.
      # If the problem already has a history entry, reset the values.
      def begin_problem(problem)
        @action = Action.find_by_class_assignment_id_and_user_id(
          @session[:assignment_id], @current_user.id)
        @action_problem = @action.action_problems.find_by_end_time(nil)

        fields = {
          :problem_id                 => problem.id,
          :start_time                 => Time.now
          #:is_first_user_visit        => !action.action_problems.any?{|ap| ap.problem_id == problem.id && ap.end_time != nil},
          #:first_assignment_answer_id => nil, 
          #:hint_percentage            => 0, 
          #:incorrect_answers          => 0
        }
        
        if @action_problem.nil?
          @action_problem = @action.action_problems.create fields
        else
          @action_problem.update_attributes fields
        end

        # Question level table
        log = QuestionLevelLog.find_by_class_assignment_id_and_user_id_and_problem_id(
                @session[:assignment_id], @current_user.id, problem.id)
        if log.nil?
          log = QuestionLevelLog.new(
          :class_assignment_id  => @session[:assignment_id],
          :user_id              => @current_user.id,
          :problem_id           => problem.id,
          :original             => problem.main? ? 1:0,
          :correct              => nil,
          :answer_id            => nil,
          :answer               => nil,
          :input_text           => nil,
          :first_action         => nil,
          :hint_count           => 0,
          :attempt_count        => 0,
          :start_time           => @action_problem.start_time,
          :end_time             => nil,
          :first_response_time  => nil,
          :bottom_hint          => nil
          )
          log.save
        end
      end
  
      # Records the end of a problem; this just updates the :end_time on the 
      # action_problem inserted by +begin_problem+
      def end_problem(problem)
        @action = Action.find_by_class_assignment_id_and_user_id(
          @session[:assignment_id], @current_user.id)
        @action_problem = action.action_problems.find_all_by_problem_id_and_end_time(
          problem.id, nil).last
        @action_problem.update_attributes(:end_time => Time.now)

        # Question level table
        log = QuestionLevelLog.find_by_class_assignment_id_and_user_id_and_problem_id(
                @session[:assignment_id], @current_user.id, problem.id)
        unless log.nil?
          log.end_time = @action_problem.end_time
          log.save
        end
      end
  
      # records a hint request and adds it to the problem log.
      def hint(hint)
        @action = Action.find_by_class_assignment_id_and_user_id(
          @session[:assignment_id], @current_user.id)
        @action_problem = action.action_problems.find_by_problem_id_and_end_time(hint.problem.id, nil)
        @action_hint = @action_problem.action_hints.create(
          :hint_id  => hint.id, 
          :time     => Time.now)

        #action_problem.hint_percentage = action_problem.action_hints.size / action_problem.problem.hints.size.to_f
        #action_problem.save!

        # Question level table
        log = QuestionLevelLog.find_by_class_assignment_id_and_user_id_and_problem_id(
                @session[:assignment_id], @current_user.id, hint.problem.id)
        unless log.nil?
          log.hint_count += 1
          log.bottom_hint = log.hint_count == @action_problem.problem.hints.size ? 1 : 0
          # If first response
          if log.first_action.nil?
            log.first_action = 1
            log.correct = 0
            log.first_response_time = @action_hint.time
          end
          log.save
        end
      end
  
      # records an answer attempt
      def answer(data)
        @action = Action.find_by_class_assignment_id_and_user_id(
          @session[:assignment_id], @current_user.id)
        @action_problem = action.action_problems.find_by_problem_id_and_end_time(data[:problem].id, nil)
        @assignment_answer = AssignmentAnswer.create(
          :action_problem_id    => @action_problem.id,
          :problem_id           => data[:problem].id, 
          :answer               => data[:correct] || data[:incorrect],  
          :correct              => data.has_key?(:correct), 
          :user_id              => @current_user.id, 
          :class_assignment_id  => @session[:assignment_id], 
          :time                 => Time.now)

        #action_problem.incorrect_answers += 1 if data.has_key?(:incorrect)
        #action_problem.first_assignment_answer_id = @assignment_answer.id if action_problem.first_assignment_answer_id.nil?
        #action_problem.save!

        if @assignment_answer.first_response? and @assignment_answer.problem.scaffold_id.nil?
          student_id = Student.find_by_user_id(@session[:user]).id
          sa = StudentAssignment.find_or_create_by_student_id_and_class_assignment_id(student_id, @session[:assignment_id])
          sa.increment(:correct_first_answers) if data[:correct] and -1 == @session[:hint_count]
          sa.increment(:all_first_answers)
          sa.save
        end
        # Question level table
        log = QuestionLevelLog.find_by_class_assignment_id_and_user_id_and_problem_id(
                @session[:assignment_id], @current_user.id, data[:problem].id)
        unless log.nil?
          # IF FIRST RESPONSE
          if log.first_action.nil?
            log.first_response_time = @assignment_answer.time
            # if request scaffold
            if @assignment_answer.answer.nil?
              log.first_action = 2
              log.correct = 0
            # if an answer
            else
              log.first_action = 0
              log.attempt_count += 1
              log.correct = @assignment_answer.correct? ? 1:0
              log.answer = @assignment_answer.answer
              if @assignment_answer.answer.class.to_s == "HashWithIndifferentAccess"
                log.answer_id = @assignment_answer.answer[:id] unless @assignment_answer.answer[:id].nil?
                log.input_text = @assignment_answer.answer[:body] unless @assignment_answer.answer[:body].nil?
              else
                log.input_text = @assignment_answer.answer
              end
            end
          # NOT THE FIRST RESPONSE
          else
            # if an answer
            unless @assignment_answer.answer.nil?
              log.attempt_count += 1
            end
          end
          log.save
        end
      end
    end
  
  end
  
end

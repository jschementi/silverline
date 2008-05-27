class Build::AnswerController < Build::DefaultController
  
  def order
    @problem = Problem.find(params[:problem_id])
    params[:answers_list].each_with_index { |id,idx| Answer.update(id, :position => idx + 1) }
    render :nothing => true
  end
  
  def hide_new
    @problem = Problem.find params[:problem_id]
  end
  
  def delete
    @answer = Answer.find(params[:id])
    @answer.destroy
    respond_to do |format|
      format.js
      format.xml { render :nothing => true, :status => "204 Deleted" }
    end
  end
  
  def new
    @answer = Answer.new(:problem_id => params[:problem_id])
  end
  
  def save
    #params[:problem_id] ||= params[:answer][:problem_id]
    @answer = Problem.find_by_id(params[:problem_id]).answers.create(params[:answer])
    @saved, @answer = @answer, Answer.new(:problem_id => params[:problem_id])
    respond_to do |format|
      format.js
      format.xml { render :xml => @saved.to_xml }
    end
  end
  
  def update
    @answer = Answer.find_by_id(params[:id])
    @answer.update_attributes params[:answer]
    respond_to do |format|
      format.js
      format.xml { render :xml => @answer.to_xml }
    end
  end
  
  def edit
    @answer = Answer.find_by_id(params[:id])
  end

  def toggle_correct
    @answer_id = if params[:id].nil? then "" else "#{params[:id]}" end
  end
  
  def restore
    @answer = Answer.find params[:id]
  end
  
end

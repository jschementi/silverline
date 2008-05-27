class Build::HintController < Build::DefaultController
  
  def hide_new
    @problem = Problem.find params[:problem_id]
  end
  
  def delete
    @hint = Hint.find(params[:id]).destroy
    respond_to do |format|
      format.js
      format.xml { render :nothing => true, :status => "204 Deleted" }
    end
  end
  
  def new
    @hint = Hint.new(:problem_id => params[:problem_id])
  end
  
  def save
    @hint = Problem.find(params[:problem_id]).hints.create(params[:hint])
    @saved, @hint = @hint, Hint.new(:problem_id => params[:problem_id])
    respond_to do |format|
      format.js
      format.xml { render :xml => @saved.to_xml }
    end
  end

  def edit
    @hint = Hint.find_by_id params[:id]
  end
  
  def update
    @hint = Hint.find_by_id(params[:id])
    @hint.update_attributes params[:hint]
    respond_to do |format|
      format.js
      format.xml { render :xml => @hint.to_xml }
    end
  end

  def restore
    @hint = Hint.find params[:id]
  end
  
  def reorder
    params[:hints_list].each_with_index {|id, idx| Hint.update(id, :position => idx + 1)}
    render :nothing => true
  end

end

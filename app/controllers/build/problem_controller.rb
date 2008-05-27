class Build::ProblemController < Build::DefaultController
  
  in_place_edit_for :assistment, :name
  in_place_edit_for :problem, :name
  
  def show
    @problem = Problem.find(params[:id])
    @assistment = @problem.assistment
    
    load_tag_helper_tree
    
    respond_to do |format|
      format.js
      format.xml { render :xml => @problem.to_xml(:include => [:scaffold, :problem_type, :answers, :hints]) }
    end
  end
  
  def create
    @scaffold = Scaffold.find params[:scaffold_id]
    assistment_id = @scaffold.problem.assistment_id
    @problem = @scaffold.problems.create(:assistment_id => assistment_id)
    respond_to do |format|
      format.js
      format.xml { render :xml => "<location>#{url_for(:action => "show", :id => @problem.id)}</location>" }
    end
  end

  def destroy
    @destroy_scaffold = false
    @problem = Problem.find_by_id(params[:id])
    @problem.destroy
    @scaffold = Scaffold.find(@problem.scaffold_id)
    if @problem.is_part_of_scaffold? and @scaffold.problems.empty?
      @destroy_scaffold = true
      Scaffold.destroy(@problem.scaffold_id)
    end
    
    respond_to do |format|
      format.js
      format.xml { render :nothing => true, :status => "204 Deleted" }
    end
  end
  
  def save
    @problem = Problem.find(params[:id])
    @problem.update_attributes(params[:problem])
    flash[:notice] = "Problem Body successfully saved"
    respond_to do |format|
      format.js
      format.xml { render :xml => @problem.to_xml }
    end
  end
  
  # Change the problem_type of this problem and save
  def save_type
    @problem = Problem.find(params[:id])
    @problem.update_attribute(:problem_type_id, params[:problem_type_id])
    flash[:notice] = "Problem Type changed to #{@problem.problem_type.description}"
    respond_to do |format|
      format.js
      format.xml { render :xml => @problem.to_xml }
    end
  end
  
  def revert_to
    @problem = Problem.find(params[:id])
    @problem.revert_to!(params[:version])
  end
  
end

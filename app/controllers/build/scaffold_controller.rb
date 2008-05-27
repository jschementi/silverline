class Build::ScaffoldController < Build::DefaultController

  # Enable scaffolds for the specified problem
  # 
  # params:
  # * :problem_id = The problem to enable scaffolding for
  def enable
    @problem = Problem.find_by_id(params[:problem_id])
    if @problem.scaffold.nil?
      @problem.create_scaffold
    end
    @problem.scaffold.update_attribute(:enabled, true)
    
    respond_to do |format|
      format.html
      format.js
      format.xml { render :xml => @problem.scaffold, :location => url_for(:action => "show", :id => @problem.scaffold.id)}
    end
  end
  
  def disable
    @problem = Problem.find_by_id(params[:problem_id])
    @problem.scaffold.update_attribute(:enabled, false)
    
    respond_to do |format|
      format.js
      format.html
      format.xml { render :xml => @problem.scaffold, :location => url_for(:action => "show", :id => @problem.scaffold.id) }
    end
  end

  def show
    @scaffold = Scaffold.find(params[:id])
    respond_to do |format|
      format.xml { render :xml => @scaffold.to_xml }
    end
  end

end

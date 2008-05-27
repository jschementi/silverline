class Build::AssistmentController < Build::DefaultController

  verify :method => :post, :only => ["create", "destroy"],
         :redirect_to => :index
  
  def index
    @assistments = Assistment.find(:all)
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @assistments.to_xml }
    end
  end
  
  def show
    @assistment = Assistment.find(params[:id])
    @problem = @assistment.problem
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @assistment.to_xml(:include => [:problems, :assistment_info]) }
    end
  end

  def create
    @assistment = Assistment.create!
    respond_to do |format|
      format.html { redirect_to :action => :show, :id => @assistment }
      format.xml do
        render :xml => @assistment.to_xml, :status => "201 Created", :location => url_for(:action => :show, :id => @assistment)
      end
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { redirect_to :action => :list }
      format.xml { render :xml => @assistment.errors.to_xml }
    end
  end

  def destroy
    @assistment = Assistment.find(params[:id])
    @assistment.destroy
    flash[:notice] = "Assistment successfully destroyed"
    respond_to do |format|
      format.html { redirect_to :action => :index }
      format.js
      format.xml { render :nothing => true, :status => "204 Deleted" }
    end
  end

end

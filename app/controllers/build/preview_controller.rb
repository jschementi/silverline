require_dependency "tutor"
Tutor.requires

class Build::PreviewController < Build::DefaultController

  layout "preview"
  
  Tutor.enable :with => :all
  include Tutor

  def sequence
    @sequence = Sequence.find params[:id]
    initialize_preview(@sequence)
    begin_sequence(@sequence)
  end
  
  def assistment
    if params[:problem].nil?
      @assistment = Assistment.find(params[:id])
    else
      @assistment = Assistment.find(Problem.find(params[:problem]).assistment.id)
    end  
    begin_assistment(@assistment)
  end

end

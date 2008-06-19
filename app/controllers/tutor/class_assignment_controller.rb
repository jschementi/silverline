Tutor.requires

class Tutor::ClassAssignmentController < Tutor::DefaultController
  layout "tutor"
  
  Tutor.enable :with => :all, :resume => :assistment
  include Tutor

  client :begin

  def list
    @assistments = Assistment.find(:all)
  end

  def begin
    begin_assistment(Assistment.find(params[:id]))
  end

end

class TryrubyController < ApplicationController
  before_filter :get_instructions

  def instructions
    respond_to do |format|
      format.json { render :json => @instructions }
    end
  end

private
  def get_instructions
    @instructions = [
      "Type: 2 + 6",
      "Type: \"Jimmy\"",
      "Type: \"Jimmy\".reverse",
      "Type: \"Jimmy\".length",
      "Type: \"Jimmy\" * 5",
      "Done! Continue to play around with IronRuby!"
    ]
  end
end

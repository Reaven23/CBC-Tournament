class RobotsController < ApplicationController
  def index
    respond_to do |format|
      format.text { render layout: false }
    end
  end
end

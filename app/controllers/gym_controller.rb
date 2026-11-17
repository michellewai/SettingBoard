class GymController < ApplicationController
  def show
    @wall_sections = WallSection.order(:id).includes(:routes)
  end
end

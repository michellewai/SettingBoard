class GradesController < ApplicationController
  def show
    @distribution = GradeDistribution.new
    @wall_sections = WallSection.order(:id)
  end
end

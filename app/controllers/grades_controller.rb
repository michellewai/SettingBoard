class GradesController < ApplicationController
  # The board is public to read; only changes need a signed-in setter.
  allow_unauthenticated_access only: :show

  def show
    @distribution = GradeDistribution.new
    @wall_sections = WallSection.order(:id)
  end
end

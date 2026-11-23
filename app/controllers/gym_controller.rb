class GymController < ApplicationController
  # The board is public to read; only changes need a signed-in setter.
  allow_unauthenticated_access only: :show

  def show
    @wall_sections = WallSection.order(:id).includes(current_routes: :setter)
    @resets_this_week = Reset.in_week_of.index_by(&:wall_section_id)
    @next_reset = Reset.next_after_week_of
  end
end

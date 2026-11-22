class WallSection < ApplicationRecord
  # Fixed ids for the gym's four sections. The ids are fixed rather than generated because
  # FloorPlan's wall geometry is keyed by them, and the seeds use them to set up the walls.
  NAMES_BY_ID = { 1 => "Back", 2 => "Slab", 3 => "Cave", 4 => "Front" }.freeze

  has_many :routes, dependent: :destroy
  has_many :current_routes, -> { current }, class_name: "Route", inverse_of: :wall_section
  has_many :resets, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # The date of this wall's most recent reset on or before date, or nil if it has none yet.
  def last_reset_on(date = Date.current) = resets.where(reset_on: ..date).maximum(:reset_on)

  # Records that this wall was reset on the given day: retires its current routes and records the reset,
  # together or not at all. Routes set earlier that same day stay up. Returns the reset.
  def reset!(on: Date.current)
    transaction do
      current_routes.where(set_date: ...on).update_all(retired_on: on, updated_at: Time.current)
      record_reset_on(on)
    end
  end

  private

  # Moves this week's scheduled reset to the day it really happened, or adds one if none was planned,
  # so the resets table records what happened rather than what was planned.
  def record_reset_on(date)
    reset = resets.find_by(reset_on: date) || resets.in_week_of(date).first || resets.build
    reset.update!(reset_on: date)
    reset
  end
end

# Manages the schedule of resets for a wall section
class Reset < ApplicationRecord
  belongs_to :wall_section

  validates :reset_on, presence: true, uniqueness: { scope: :wall_section_id }

  scope :chronological, -> { order(:reset_on) }

  # Empty when that week is skipped.
  def self.in_week_of(date = Date.current) = where(reset_on: date.all_week).chronological

  # The first reset after the week containing date, skipping any weeks without one.
  def self.next_after_week_of(date = Date.current)
    where(reset_on: date.end_of_week.next_day..).chronological.first
  end
end

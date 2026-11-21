class WallSection < ApplicationRecord
  # TODO: refactor so that it doesn't have to be hard-coded here
  # Fixed ids for the gym's four sections.
  NAMES_BY_ID = { 1 => "Back", 2 => "Slab", 3 => "Cave", 4 => "Front" }.freeze

  has_many :routes, dependent: :destroy
  has_many :resets, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # The date of this wall's most recent reset on or before date, or nil if it has none yet.
  def last_reset_on(date = Date.current) = resets.where(reset_on: ..date).maximum(:reset_on)
end

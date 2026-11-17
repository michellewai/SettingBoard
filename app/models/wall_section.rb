class WallSection < ApplicationRecord
  # Fixed ids for the gym's four sections.
  NAMES_BY_ID = { 1 => "Back", 2 => "Slab", 3 => "Cave", 4 => "Front" }.freeze

  has_many :routes, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end

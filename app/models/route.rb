class Route < ApplicationRecord
  belongs_to :wall_section

  validates :grade, :colour, :set_date, :setter, presence: true
end

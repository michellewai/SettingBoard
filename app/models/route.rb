class Route < ApplicationRecord
  # Hold colours that need dark text on top of them to stay readable.
  LIGHT_COLOURS = %w[white yellow pink orange].freeze

  belongs_to :wall_section
  belongs_to :setter

  validates :grade, :colour, :set_date, presence: true

  # Hold colours are stored as plain names ("Green"), which double as CSS colour keywords.
  def css_colour = colour.downcase

  def light_colour? = LIGHT_COLOURS.include?(css_colour)
end

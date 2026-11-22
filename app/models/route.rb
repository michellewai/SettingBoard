class Route < ApplicationRecord
  # Hold colours that need dark text on top of them to stay readable.
  LIGHT_COLOURS = %w[white yellow pink orange].freeze

  # The gym's bouldering grades, easiest first. Stored as the number, so 5 is V5.
  GRADES = (0..10)

  belongs_to :wall_section
  belongs_to :setter

  validates :grade, :colour, :set_date, presence: true
  # Numericality checks the value as given, so "V5" is rejected rather than cast to 0.
  validates :grade, numericality: { only_integer: true, in: GRADES }, allow_nil: true
  validates :retired_on, comparison: { greater_than_or_equal_to: :set_date }, allow_nil: true, if: :set_date

  # Routes are never deleted at a reset; retired_on records the day they came down.
  scope :current, -> { where(retired_on: nil) }
  scope :retired, -> { where.not(retired_on: nil) }
  # Routes up on date: set by then and not yet retired. Gives the grade mix for any past day.
  scope :on, ->(date) { where(set_date: ..date).where("retired_on IS NULL OR retired_on > ?", date) }

  def self.grade_label(grade) = "V#{grade}"

  def grade_label = self.class.grade_label(grade)

  # Hold colours are stored as plain names ("Green"), which double as CSS colour keywords.
  def css_colour = colour.downcase

  def light_colour? = LIGHT_COLOURS.include?(css_colour)
end

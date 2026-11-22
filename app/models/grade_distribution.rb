# How many routes are up at each grade, for the whole gym and for each wall section.
class GradeDistribution
  def initialize(routes = Route.current)
    @counts = routes.group(:wall_section_id, :grade).count
  end

  # Routes of grade on wall_section, or across the whole gym when wall_section is nil.
  def count(grade, wall_section = nil)
    @counts.sum { |(section_id, g), n| g == grade && matches?(section_id, wall_section) ? n : 0 }
  end

  # All routes on wall_section, or across the whole gym when wall_section is nil.
  def total(wall_section = nil)
    @counts.sum { |(section_id, _), n| matches?(section_id, wall_section) ? n : 0 }
  end

  # The highest gym-wide count of any one grade, or 0 when there are no routes.
  def max_count = Route::GRADES.map { |grade| count(grade) }.max

  private

  def matches?(section_id, wall_section) = wall_section.nil? || section_id == wall_section.id
end

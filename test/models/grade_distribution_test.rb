require "test_helper"

class GradeDistributionTest < ActiveSupport::TestCase
  setup { @distribution = GradeDistribution.new }

  test "counts routes of each grade across the gym" do
    assert_equal 1, @distribution.count(2)
    assert_equal 1, @distribution.count(5)
    assert_equal 0, @distribution.count(0)
  end

  test "counts routes of each grade on one wall" do
    assert_equal 1, @distribution.count(2, wall_sections(:slab))
    assert_equal 0, @distribution.count(5, wall_sections(:slab))
    assert_equal 1, @distribution.count(5, wall_sections(:cave))
    assert_equal 0, @distribution.count(2, wall_sections(:back))
  end

  test "totals routes for the gym and per wall" do
    assert_equal 2, @distribution.total
    assert_equal 1, @distribution.total(wall_sections(:slab))
    assert_equal 0, @distribution.total(wall_sections(:back))
  end

  test "max_count is the highest gym-wide count for one grade" do
    wall_sections(:front).routes.create!(grade: 2, colour: "Blue", set_date: Date.current, setter: setters(:sam))

    assert_equal 2, GradeDistribution.new.max_count
  end

  test "max_count is 0 with no routes" do
    assert_equal 0, GradeDistribution.new(Route.none).max_count
  end
end

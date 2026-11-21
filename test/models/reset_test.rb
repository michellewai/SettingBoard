require "test_helper"

class ResetTest < ActiveSupport::TestCase
  test "requires a wall section and a date" do
    reset = Reset.new
    assert_not reset.valid?
    assert_equal %i[reset_on wall_section], reset.errors.attribute_names.sort
  end

  test "a wall can only be reset once a day, but walls can share a day" do
    assert_not Reset.new(wall_section: wall_sections(:slab), reset_on: Date.new(2026, 11, 10)).valid?
    assert Reset.new(wall_section: wall_sections(:front), reset_on: Date.new(2026, 11, 10)).valid?
  end

  test "in_week_of finds a reset moved off Monday" do
    assert_equal [ resets(:slab_nov_10) ], Reset.in_week_of(Date.new(2026, 11, 12)).to_a
  end

  test "in_week_of runs Monday to Sunday" do
    assert_equal [ resets(:slab_nov_10) ], Reset.in_week_of(Date.new(2026, 11, 15)).to_a # Sunday
    assert_equal [ resets(:cave_nov_16) ], Reset.in_week_of(Date.new(2026, 11, 16)).to_a # Monday
  end

  test "in_week_of is empty for a skipped week" do
    assert_empty Reset.in_week_of(Date.new(2026, 11, 25))
  end

  test "next_after_week_of finds the next week's reset" do
    assert_equal resets(:slab_nov_10), Reset.next_after_week_of(Date.new(2026, 11, 4))
  end

  test "next_after_week_of jumps over a skipped week" do
    assert_equal resets(:front_nov_30), Reset.next_after_week_of(Date.new(2026, 11, 18))
  end

  test "next_after_week_of is nil when nothing is planned" do
    assert_nil Reset.next_after_week_of(Date.new(2026, 11, 30))
  end
end

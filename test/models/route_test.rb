require "test_helper"

class RouteTest < ActiveSupport::TestCase
  test "belongs to a wall section and a setter" do
    route = routes(:cave_v5)
    assert_equal wall_sections(:cave), route.wall_section
    assert_equal setters(:sam), route.setter
  end

  test "requires a wall section, grade, colour, set date and setter" do
    route = Route.new
    assert_not route.valid?
    assert_equal %i[colour grade set_date setter wall_section], route.errors.attribute_names.sort
  end

  test "requires a whole-number grade from 0 to 10" do
    route = routes(:slab_v2)
    route.grade = 10
    assert route.valid?

    [ 11, -1, 2.5, "V5", "5.10a" ].each do |grade|
      route.grade = grade
      assert_not route.valid?, "#{grade.inspect} should be invalid"
      assert_includes route.errors.attribute_names, :grade
    end
  end

  test "can't be retired before it was set, but can be retired the day it was set" do
    route = routes(:slab_v2) # set 10 Nov

    route.retired_on = Date.new(2026, 11, 9)
    assert_not route.valid?
    assert_includes route.errors.attribute_names, :retired_on

    route.retired_on = Date.new(2026, 11, 10)
    assert route.valid?
  end

  test "current routes are the ones not retired, and retired routes are the rest" do
    assert_equal [ routes(:cave_v5), routes(:slab_v2) ].sort_by(&:id), Route.current.sort_by(&:id)
    assert_equal [ routes(:slab_v7_retired) ], Route.retired.to_a
  end

  test "on finds the routes up on a given day" do
    # slab_v7_retired: up 13 Oct until 10 Nov. slab_v2: set 10 Nov. cave_v5: set 12 Nov.
    assert_empty Route.on(Date.new(2026, 10, 12))
    assert_equal [ routes(:slab_v7_retired) ], Route.on(Date.new(2026, 10, 13)).to_a
    assert_equal [ routes(:slab_v7_retired) ], Route.on(Date.new(2026, 11, 9)).to_a
    assert_equal [ routes(:slab_v2) ], Route.on(Date.new(2026, 11, 10)).to_a, "retired on the day the new route went up"
    assert_equal [ routes(:cave_v5), routes(:slab_v2) ].sort_by(&:id), Route.on(Date.new(2026, 11, 12)).sort_by(&:id)
  end

  test "labels the grade with a V" do
    assert_equal "V5", routes(:cave_v5).grade_label
    assert_equal "V10", Route.grade_label(10)
  end
end

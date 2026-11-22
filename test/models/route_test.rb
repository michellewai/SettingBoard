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

  test "labels the grade with a V" do
    assert_equal "V5", routes(:cave_v5).grade_label
    assert_equal "V10", Route.grade_label(10)
  end
end

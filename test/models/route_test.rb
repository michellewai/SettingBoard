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
end

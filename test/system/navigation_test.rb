require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  test "switches between the Wall map and Grades tabs" do
    visit root_path
    assert_selector ".tabs a[aria-current=page]", text: "Wall map"

    click_on "Grades"
    assert_current_path grades_path
    assert_selector "h2", text: "Routes per grade"
    assert_selector ".tabs a[aria-current=page]", count: 1, text: "Grades"

    click_on "Wall map"
    assert_current_path root_path
    assert_selector "svg.floor-plan"
    assert_selector ".tabs a[aria-current=page]", count: 1, text: "Wall map"
  end

  test "clicking a wall on the map jumps to its route card" do
    visit root_path

    find("svg .wall-label", text: "Cave").click

    assert_equal "#wall_section_3", evaluate_script("location.hash")
    card = rect("#wall_section_3")
    assert_operator card["top"], :>=, 0
    assert_operator card["top"], :<, evaluate_script("window.innerHeight")
  end
end

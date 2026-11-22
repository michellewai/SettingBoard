require "application_system_test_case"

class GradesTest < ApplicationSystemTestCase
  # Fixtures have one V2 route (Slab) and one V5 route (Cave), so both are the gym-wide maximum.
  V0_BAR = ".grade-chart tbody tr:nth-child(1) .grade-chart__bar span"
  V2_BAR = ".grade-chart tbody tr:nth-child(3) .grade-chart__bar span"
  V5_BAR = ".grade-chart tbody tr:nth-child(6) .grade-chart__bar span"

  CHART_PANEL = ".grade-panel:nth-child(1)"
  TABLE_PANEL = ".grade-panel:nth-child(2)"

  test "draws each grade's bar in proportion to its route count" do
    visit grades_path

    assert_operator rect(V2_BAR)["width"], :>, 0
    assert_equal rect(V2_BAR)["width"], rect(V5_BAR)["width"]
    assert_equal 0, rect(V0_BAR)["width"]
  end

  test "puts the chart and the per-wall table side by side, with each grade on the same line" do
    visit grades_path

    chart, table = rect(CHART_PANEL), rect(TABLE_PANEL)
    assert_equal chart["top"], table["top"]
    assert_operator table["left"], :>, chart["right"]

    assert_equal rect(".grade-chart tbody tr:nth-child(6)")["top"],
                 rect(".grade-walls tbody tr:nth-child(6)")["top"]
  end

  test "stacks the per-wall table under the chart on a narrow screen" do
    visit grades_path
    page.current_window.resize_to(400, 900)

    assert_operator rect(TABLE_PANEL)["top"], :>=, rect(CHART_PANEL)["bottom"]
  end
end

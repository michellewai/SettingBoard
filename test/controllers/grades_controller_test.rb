require "test_helper"

class GradesControllerTest < ActionDispatch::IntegrationTest
  test "shows a gym-wide bar for every grade with its route count" do
    get grades_url

    assert_response :success
    assert_select ".grade-chart tbody tr", Route::GRADES.count
    assert_select ".grade-chart tbody tr:nth-child(3)" do
      assert_select "th", text: "V2"
      assert_select ".grade-chart__count", text: "1"
      assert_select ".grade-chart__bar span[style*='--share: 100.0%']"
    end
    assert_select ".grade-chart tbody tr:nth-child(6)" do
      assert_select "th", text: "V5"
      assert_select ".grade-chart__count", text: "1"
    end
    assert_select ".grade-chart tbody tr:nth-child(1) .grade-chart__count", text: "0"
  end

  test "draws empty bars when there are no routes" do
    Route.delete_all

    get grades_url

    assert_response :success
    assert_select ".grade-chart__bar span[style*='--share: 0%']", Route::GRADES.count
  end

  test "shows route counts per grade for each wall, with gym and wall totals" do
    get grades_url

    assert_equal %w[Grade Back Slab Cave Front Gym], css_select(".grade-walls thead th").map { it.text.strip }
    assert_select ".grade-walls thead th[style*='--wall-colour: #c4aead']", text: "Slab"

    # Columns: 1 Grade, 2 Back, 3 Slab, 4 Cave, 5 Front, 6 Gym
    assert_select ".grade-walls tbody tr:nth-child(3)" do # V2
      assert_select "td:nth-child(3)", text: "1"
      assert_select "td:nth-child(6)", text: "1"
    end
    assert_select ".grade-walls tbody tr:nth-child(6)" do # V5
      assert_select "td:nth-child(4)", text: "1"
      assert_select "td:nth-child(3).grade-walls__zero", text: "–"
    end
    assert_select ".grade-walls tbody tr:nth-child(1) td.grade-walls__zero", 5

    assert_select ".grade-walls tfoot th", text: "Total"
    assert_equal %w[– 1 1 – 2], css_select(".grade-walls tfoot td").map { it.text.strip }
  end

  test "marks the Grades tab as the current page" do
    get grades_url

    assert_select ".tabs a[aria-current=page]", count: 1, text: "Grades"
  end
end

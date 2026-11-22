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

  test "marks the Grades tab as the current page" do
    get grades_url

    assert_select ".tabs a[aria-current=page]", count: 1, text: "Grades"
  end
end

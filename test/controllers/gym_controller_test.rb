require "test_helper"

class GymControllerTest < ActionDispatch::IntegrationTest
  test "shows the wall map with every section and its routes" do
    get root_url

    assert_response :success
    assert_select "svg.floor-plan .wall", 4
    assert_select "svg.floor-plan .route-marker", Route.count
    assert_select "section.section", 4
    assert_select "#wall_section_3 tbody tr", 1 do
      assert_select "td", text: "V5"
      assert_select "td", text: "Sam"
    end
    assert_select "#wall_section_1 .empty", text: "No routes set."
  end
end

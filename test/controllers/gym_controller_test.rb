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

  test "shows both tabs with Wall map as the current page" do
    get root_url

    assert_select ".tabs a", 2
    assert_select ".tabs a[href='#{grades_path}']", text: "Grades"
    assert_select ".tabs a[aria-current=page]", count: 1, text: "Wall map"
  end

  test "highlights this week's reset, even when moved off Monday, and the next one" do
    travel_to Time.zone.local(2026, 11, 12) do
      get root_url
    end

    assert_select ".wall--reset-now", 1 do
      assert_select ".wall-label", text: "Slab"
    end
    assert_select ".wall--reset-next", 1 do
      assert_select ".wall-label", text: "Cave"
    end
    assert_select "#wall_section_2 .reset-note--now", text: "New this week! · Tue 10 Nov"
    assert_select "#wall_section_3 .reset-note--next", text: "Last chance! Next reset · Mon 16 Nov"
  end

  test "highlights nothing this week when the reset is skipped, and the next one after it" do
    travel_to Time.zone.local(2026, 11, 25) do
      get root_url
    end

    assert_select ".wall--reset-now", 0
    assert_select ".reset-note--now", 0
    assert_select ".wall--reset-next", 1 do
      assert_select ".wall-label", text: "Front"
    end
    assert_select "#wall_section_4 .reset-note--next", text: "Last chance! Next reset · Mon 30 Nov"
  end
end

require "test_helper"

class WallSectionTest < ActiveSupport::TestCase
  test "has the four gym sections with fixed ids" do
    assert_equal({ 1 => "Back", 2 => "Slab", 3 => "Cave", 4 => "Front" }, WallSection.pluck(:id, :name).to_h)
  end

  test "requires a unique name" do
    assert_not WallSection.new(name: "").valid?
    assert_not WallSection.new(name: "Slab").valid?
  end

  test "has many routes" do
    assert_includes wall_sections(:slab).routes, routes(:slab_v2)
  end

  test "has many resets" do
    assert_equal [ resets(:slab_nov_10) ], wall_sections(:slab).resets.to_a
  end

  test "last_reset_on is the latest reset on or before the date" do
    slab = wall_sections(:slab)
    assert_nil slab.last_reset_on(Date.new(2026, 11, 9))
    assert_equal Date.new(2026, 11, 10), slab.last_reset_on(Date.new(2026, 11, 10))
    assert_equal Date.new(2026, 11, 10), slab.last_reset_on(Date.new(2026, 12, 25))
  end
end

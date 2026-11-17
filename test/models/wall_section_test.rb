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
end

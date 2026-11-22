require "test_helper"

class FloorPlanTest < ActiveSupport::TestCase
  # Slab is one straight segment, 268 long: [250, 131] to [518, 131].
  # Cave turns one corner: 155 along [518, 131] to [673, 131], then 119 down to [673, 250].
  # Back turns two corners: 155 along, 224 down, then 160 along, 539 in all.
  SLAB = FloorPlan::WALLS.fetch(2)
  CAVE = FloorPlan::WALLS.fetch(3)
  BACK = FloorPlan::WALLS.fetch(1)

  test "puts a single marker in the middle of the wall" do
    assert_equal [ [ 384.0, 131.0 ] ], SLAB.marker_positions(1)
  end

  test "keeps the end markers 16 away from each end of the wall" do
    # 16 along from [518, 131], and 16 back up from [673, 250] after the corner.
    assert_equal [ [ 534.0, 131.0 ], [ 673.0, 234.0 ] ], CAVE.marker_positions(2)
  end

  test "spaces markers evenly along the wall, around its corners" do
    # 507 usable after the end gaps, so markers at 16, 269.5 and 523 along the wall:
    # on the first segment, 114.5 down the second, and 144 along the third.
    assert_equal [ [ 234.0, 131.0 ], [ 95.0, 245.5 ], [ 239.0, 355.0 ] ], BACK.marker_positions(3)
  end

  test "has no markers for a wall with no routes" do
    assert_equal [], SLAB.marker_positions(0)
  end

  test "draws svg points as space-separated x,y pairs" do
    assert_equal "518,131 673,131 673,250", CAVE.svg_points
  end

  test "finds the wall for a section, and fails for a section not on the map" do
    assert_same SLAB, FloorPlan.wall_for(wall_sections(:slab))
    assert_raises(KeyError) { FloorPlan.wall_for(WallSection.new(id: 99)) }
  end
end

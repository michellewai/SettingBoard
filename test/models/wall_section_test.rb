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

  # Cave's reset is scheduled for Monday 16 Nov, and cave_v5 has been up since 12 Nov.
  TUESDAY = Date.new(2026, 11, 17)

  test "reset! retires the wall's current routes on the day" do
    wall_sections(:cave).reset!(on: TUESDAY)

    assert_equal TUESDAY, routes(:cave_v5).reload.retired_on
    assert_empty wall_sections(:cave).current_routes
  end

  test "reset! leaves other walls' routes up" do
    wall_sections(:cave).reset!(on: TUESDAY)

    assert_nil routes(:slab_v2).reload.retired_on
  end

  test "reset! keeps routes set earlier the same day" do
    cave = wall_sections(:cave)
    new_route = cave.routes.create!(grade: 4, colour: "Blue", set_date: TUESDAY, setter: setters(:jo))

    cave.reset!(on: TUESDAY)

    assert_nil new_route.reload.retired_on
    assert_equal [ new_route ], cave.current_routes.to_a
  end

  test "reset! doesn't change routes that were already retired" do
    wall_sections(:slab).reset!(on: Date.new(2026, 11, 24))

    assert_equal Date.new(2026, 11, 10), routes(:slab_v7_retired).reload.retired_on
    assert_equal Date.new(2026, 11, 24), routes(:slab_v2).reload.retired_on
  end

  test "reset! moves the week's scheduled reset to the day it happened" do
    reset = assert_no_difference("Reset.count") { wall_sections(:cave).reset!(on: TUESDAY) }

    assert_equal resets(:cave_nov_16), reset
    assert_equal TUESDAY, reset.reload.reset_on
  end

  test "reset! records an unplanned reset" do
    # Back's only reset is 2 Nov, so nothing is planned for the week of 23 Nov.
    reset = assert_difference("Reset.count") { wall_sections(:back).reset!(on: Date.new(2026, 11, 25)) }

    assert_equal [ wall_sections(:back), Date.new(2026, 11, 25) ], [ reset.wall_section, reset.reset_on ]
  end

  test "reset! keeps a reset that's already on the day" do
    reset = assert_no_difference("Reset.count") { wall_sections(:slab).reset!(on: Date.new(2026, 11, 10)) }

    assert_equal resets(:slab_nov_10), reset
  end

  test "reset! defaults to today" do
    travel_to TUESDAY do
      wall_sections(:cave).reset!
    end

    assert_equal TUESDAY, resets(:cave_nov_16).reload.reset_on
    assert_equal TUESDAY, routes(:cave_v5).reload.retired_on
  end

  test "reset! changes nothing if recording the reset fails" do
    cave = wall_sections(:cave)
    cave.define_singleton_method(:record_reset_on) { |_date| raise ActiveRecord::RecordInvalid }

    assert_raises(ActiveRecord::RecordInvalid) { cave.reset!(on: TUESDAY) }

    assert_nil routes(:cave_v5).reload.retired_on
    assert_equal Date.new(2026, 11, 16), resets(:cave_nov_16).reload.reset_on
  end
end

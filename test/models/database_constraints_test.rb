require "test_helper"

# The database rejects bad data on its own, not only through model validations, so a console,
# script or bulk insert can't get it in. insert! and delete_all skip validations and callbacks.
# (insert! rather than insert: on MySQL, insert quietly skips duplicate rows instead of raising.)
class DatabaseConstraintsTest < ActiveSupport::TestCase
  setup do
    @route = { wall_section_id: wall_sections(:back).id, setter_id: setters(:jo).id,
               grade: 3, colour: "Blue", set_date: Date.current }
  end

  test "accepts a valid route inserted without validations" do
    assert_difference("Route.count") { Route.insert!(@route) }
  end

  test "routes must belong to a wall section and setter that exist" do
    assert_raises(ActiveRecord::InvalidForeignKey) { Route.insert!(@route.merge(wall_section_id: 0)) }
    assert_raises(ActiveRecord::InvalidForeignKey) { Route.insert!(@route.merge(setter_id: 0)) }
    assert_raises(ActiveRecord::InvalidForeignKey) { Reset.insert!({ wall_section_id: 0, reset_on: Date.current }) }
  end

  test "routes need a grade, colour, set date, wall section and setter" do
    %i[grade colour set_date wall_section_id setter_id].each do |column|
      assert_raises(ActiveRecord::NotNullViolation, "#{column} can be null") { Route.insert!(@route.merge(column => nil)) }
    end
  end

  test "grades must be on the V0 to V10 scale" do
    assert_raises(ActiveRecord::CheckViolation) { Route.insert!(@route.merge(grade: -1)) }
    assert_raises(ActiveRecord::CheckViolation) { Route.insert!(@route.merge(grade: 11)) }
    assert_difference("Route.count", 2) { Route.insert_all!([ @route.merge(grade: 0), @route.merge(grade: 10) ]) }
  end

  test "setter and wall section names are unique" do
    assert_raises(ActiveRecord::RecordNotUnique) { Setter.insert!({ name: "Sam" }) }
    assert_raises(ActiveRecord::RecordNotUnique) { WallSection.insert!({ name: "Slab" }) }
  end

  test "a wall can only be reset once a day" do
    reset = resets(:slab_nov_10)

    assert_raises(ActiveRecord::RecordNotUnique) do
      Reset.insert!({ wall_section_id: reset.wall_section_id, reset_on: reset.reset_on })
    end
  end

  test "a wall or setter can't be deleted while it still has routes" do
    assert_raises(ActiveRecord::InvalidForeignKey) { WallSection.where(id: wall_sections(:cave).id).delete_all }
    assert_raises(ActiveRecord::InvalidForeignKey) { Setter.where(id: setters(:sam).id).delete_all }
  end
end

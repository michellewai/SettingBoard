require "test_helper"

class SetterTest < ActiveSupport::TestCase
  test "requires a unique name" do
    assert_not Setter.new(name: "").valid?
    assert_not Setter.new(name: "Alex").valid?
    assert Setter.new(name: "Riley").valid?
  end

  test "has many routes" do
    assert_equal [ routes(:slab_v2) ], setters(:alex).routes.to_a
  end

  test "cannot be deleted while it has routes" do
    assert_not setters(:alex).destroy
    assert setters(:jo).destroy
  end
end

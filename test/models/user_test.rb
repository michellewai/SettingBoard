require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "belongs to a setter and goes by the setter's name" do
    assert_equal setters(:alex), users(:alex).setter
    assert_equal "Alex", users(:alex).name
    assert_equal users(:alex), setters(:alex).user
  end

  test "requires an email address, a password and a setter" do
    user = User.new
    assert_not user.valid?
    assert_equal %i[email_address password setter], user.errors.attribute_names.sort
  end

  test "allows one account per email address and per setter" do
    user = User.new(email_address: "ALEX@example.com", password: "a long secret", setter: setters(:alex))
    assert_not user.valid?
    assert_equal %i[email_address setter], user.errors.attribute_names.sort

    assert User.new(email_address: "jo@example.com", password: "a long secret", setter: setters(:jo)).valid?
  end

  test "requires a password of at least 12 characters" do
    user = User.new(email_address: "jo@example.com", setter: setters(:jo))

    user.password = "x" * 11
    assert_not user.valid?
    assert_equal [ "is too short (minimum is 12 characters)" ], user.errors[:password]

    user.password = "x" * 12
    assert user.valid?
  end

  test "reports a missing password once" do
    user = User.new(email_address: "jo@example.com", setter: setters(:jo), password: "")
    assert_not user.valid?
    assert_equal [ "can't be blank" ], user.errors[:password]
  end

  test "can be updated without giving the password again" do
    assert User.find(users(:alex).id).update(email_address: "alex.new@example.com")
  end

  test "authenticates only with the right password" do
    assert_equal users(:alex), User.authenticate_by(email_address: "alex@example.com", password: "password")
    assert_nil User.authenticate_by(email_address: "alex@example.com", password: "wrong")
  end
end

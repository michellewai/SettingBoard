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
    user = User.new(email_address: "ALEX@example.com", password: "secret", setter: setters(:alex))
    assert_not user.valid?
    assert_equal %i[email_address setter], user.errors.attribute_names.sort

    assert User.new(email_address: "jo@example.com", password: "secret", setter: setters(:jo)).valid?
  end

  test "authenticates only with the right password" do
    assert_equal users(:alex), User.authenticate_by(email_address: "alex@example.com", password: "password")
    assert_nil User.authenticate_by(email_address: "alex@example.com", password: "wrong")
  end
end

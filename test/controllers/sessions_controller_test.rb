require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:alex) }

  test "shows the sign-in form with labelled fields" do
    get new_session_path

    assert_response :success
    assert_select "form[action='#{session_path}']" do
      assert_select "label[for=email_address]", text: "Email address"
      assert_select "label[for=password]", text: "Password"
    end
  end

  test "signs in with the right password and shows who is signed in" do
    post session_path, params: { email_address: "  ALEX@example.com ", password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
    follow_redirect!
    assert_select ".flash--notice", text: "Signed in as Alex."
    assert_select ".account", text: /Signed in as\s+Alex/
  end

  test "rejects a wrong password" do
    assert_no_difference("Session.count") do
      post session_path, params: { email_address: @user.email_address, password: "wrong" }
    end

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
    follow_redirect!
    assert_select ".flash--alert", text: "Try another email address or password."
  end

  test "rejects an unknown email address" do
    post session_path, params: { email_address: "nobody@example.com", password: "password" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "blocks an 11th sign-in attempt within 3 minutes, even with the right password" do
    with_rate_limit_counting do
      10.times do
        attempt_sign_in "wrong"
        assert_equal "Try another email address or password.", flash[:alert]
      end

      assert_no_difference("Session.count") { attempt_sign_in "password" }
      assert_redirected_to new_session_path
      assert_equal "Try again later.", flash[:alert]
    end
  end

  test "allows sign-in again once 3 minutes have passed" do
    with_rate_limit_counting do
      freeze_time
      11.times { attempt_sign_in "wrong" }

      travel 3.minutes - 1.second
      assert_no_difference("Session.count") { attempt_sign_in "password" }

      travel 2.seconds
      assert_difference("Session.count") { attempt_sign_in "password" }
    end
  end

  test "counts sign-in attempts separately for each IP address" do
    with_rate_limit_counting do
      11.times { attempt_sign_in "wrong" }

      assert_difference("Session.count") { attempt_sign_in "password", from: "203.0.113.9" }
    end
  end

  test "sends someone signed out to the sign-in page for actions that need an account" do
    delete session_path

    assert_redirected_to new_session_path
  end

  test "signs out back to the public board" do
    sign_in_as(@user)

    assert_difference("Session.count", -1) { delete session_path }

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end

  private

  def attempt_sign_in(password, from: "127.0.0.1")
    post session_path, params: { email_address: @user.email_address, password: }, env: { "REMOTE_ADDR" => from }
  end

  # The test environment's null cache never counts, which turns the rate limit off. The limiter keeps the
  # store it was given when the controller loaded, so count in a real cache through that same store.
  def with_rate_limit_counting
    counts = ActiveSupport::Cache::MemoryStore.new
    store = SessionsController.cache_store
    store.define_singleton_method(:increment) { |*args, **options| counts.increment(*args, **options) }
    yield
  ensure
    store.singleton_class.remove_method(:increment)
  end
end

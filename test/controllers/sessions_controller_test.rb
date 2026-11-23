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
end

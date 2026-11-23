require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  # Stands in for any controller that needs a signed-in setter.
  class ProtectedController < ApplicationController
    def show = render(plain: "Hello #{Current.user.name}")
    def create = head(:created)
  end

  with_routing do |set|
    set.draw do
      root "gym#show"
      get "grades" => "grades#show"
      resource :session, only: %i[new create destroy]
      resource :protected, only: %i[show create], controller: "authentication_test/protected"
    end
  end

  test "returns to the page that asked for sign-in" do
    get "/protected?from=link"
    assert_redirected_to "/session/new"

    sign_in_with_password
    assert_redirected_to "/protected?from=link"
    follow_redirect!
    assert_equal "Hello Alex", response.body
  end

  test "returns to the page a HEAD request asked for" do
    head "/protected"
    assert_redirected_to "/session/new"

    sign_in_with_password
    assert_redirected_to "/protected"
  end

  test "goes to the board after sign-in when a form submission asked for it" do
    post "/protected"
    assert_redirected_to "/session/new"

    sign_in_with_password
    assert_redirected_to "/"
  end

  test "goes to the board after sign-in when signing out asked for it" do
    delete "/session"
    assert_redirected_to "/session/new"

    sign_in_with_password
    assert_redirected_to "/"
  end

  test "starts a new browser session at sign-in and at sign-out" do
    get "/protected"
    signed_out = session.id.to_s
    assert_not_empty signed_out

    sign_in_with_password
    signed_in = session.id.to_s
    assert_not_equal signed_out, signed_in

    delete "/session"
    assert_not_equal signed_in, session.id.to_s
  end

  test "stays signed in until the session expires" do
    sign_in_as users(:alex)

    travel Session::LIFETIME - 1.minute do
      get "/protected"
      assert_response :success
    end

    travel Session::LIFETIME + 1.minute do
      get "/protected"
      assert_redirected_to "/session/new"
    end
  end

  test "the sign-in cookie expires with the session and is hidden from scripts" do
    freeze_time
    sign_in_with_password

    cookie = Array(response.headers["Set-Cookie"]).flat_map(&:lines).find { it.start_with?("session_id=") }
    assert_match(/expires=#{Regexp.escape(Session::LIFETIME.from_now.httpdate)}/i, cookie)
    assert_match(/httponly/i, cookie)
    assert_match(/samesite=lax/i, cookie)
  end

  test "rejects a forged cookie" do
    cookies["session_id"] = users(:alex).sessions.create!.id.to_s

    get "/protected"
    assert_redirected_to "/session/new"
  end

  test "a copied cookie stops working after signing out" do
    sign_in_with_password
    copied = cookies["session_id"]
    delete "/session"

    cookies["session_id"] = copied
    get "/protected"
    assert_redirected_to "/session/new"
  end

  private

  def sign_in_with_password
    post "/session", params: { email_address: "alex@example.com", password: "password" }
  end
end

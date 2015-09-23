require 'test_helper'

class AuthenticationControllerTest < ActionController::TestCase

  tests HomeController

  test "accesing root without authenticating a user redirects to sign in" do
    get :show

    assert_redirection_to_sign_in
  end

  test "accesing root with a valid authentication hash signs in the user" do
    token = ProxyAuthentication::AuthenticationCipher.encode user, request

    get :show, u: token

    assert_successful_sign_in
  end

  test "accesing root with a authentication hash from a different ip address redirects to sign in" do
    token = ProxyAuthentication::AuthenticationCipher.encode user, ActionDispatch::Request.new('REMOTE_ADDR' => '1.2.3.4')

    get :show, u: token

    assert_redirection_to_sign_in
  end

  test "accesing root with an invalid authentication hash redirects to sign in" do
    get :show, u: 'not a valid hash'

    assert_redirection_to_sign_in
  end

  test "accesing root after a valid session was created doesn't require sign in" do
    sign_in user

    get :show

    assert_successful_sign_in
  end

  test "accesing root with a valid authentication hash after a valid session was created should change the current user" do
    sign_in user
    other_user = User.new 2, 'Other User', 'other_user@example.com'
    token = ProxyAuthentication::AuthenticationCipher.encode other_user, request

    get :show, u: token

    assert_equal other_user.id, @controller.current_user.id
  end

  private

  def user
    @user = User.new 1, 'User', 'user@example.com'
  end

  def assert_redirection_to_sign_in
    assert_response :redirect
    assert_redirected_to ProxyAuthentication.redirect_to_if_authentication_failed
    refute @controller.user_signed_in?
    assert_nil @controller.current_user
  end

  def assert_successful_sign_in
    assert_response :success
    assert @controller.user_signed_in?
    assert_not_nil @controller.current_user
  end

end

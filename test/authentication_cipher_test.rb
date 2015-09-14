require 'test_helper'

class AuthenticationCipherTest < ActiveSupport::TestCase

  test "user remains the same" do
    token = ProxyAuthentication::AuthenticationCipher.encode user
    assert_equal user, ProxyAuthentication::AuthenticationCipher.decode(token)
  end

  test "returns nil if the ip addresses are different" do
    token   = ProxyAuthentication::AuthenticationCipher.encode user, ActionDispatch::Request.new('REMOTE_ADDR' => '1.2.3.4')
    decoded = ProxyAuthentication::AuthenticationCipher.decode token, ActionDispatch::Request.new('REMOTE_ADDR' => '0.0.0.0')
    assert_nil decoded
  end

  private

  def user
    User.new 1, 'User', 'user@example.com'
  end

end

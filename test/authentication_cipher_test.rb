require 'test_helper'

class AuthenticationCipherTest < ActiveSupport::TestCase

  test "user remains the same" do
    token = ProxyAuthentication::AuthenticationCipher.encode user
    assert_equal user, ProxyAuthentication::AuthenticationCipher.decode(token)
  end

  test "if no validation block is provided, returns something if the ip addresses are the same" do
    request = ActionDispatch::Request.new 'REMOTE_ADDR' => '1.2.3.4'
    token   = ProxyAuthentication::AuthenticationCipher.encode user, request
    decoded = ProxyAuthentication::AuthenticationCipher.decode token, request
    assert_not_nil decoded
  end

  test "if no validation block is provided, returns nil if the ip addresses are different" do
    token   = ProxyAuthentication::AuthenticationCipher.encode user, ActionDispatch::Request.new('REMOTE_ADDR' => '1.2.3.4')
    decoded = ProxyAuthentication::AuthenticationCipher.decode token, ActionDispatch::Request.new('REMOTE_ADDR' => '0.0.0.0')
    assert_nil decoded
  end

  test "call the validation block, if provided" do
    validation_block = -> {}
    validation_block.expects :call
    ProxyAuthentication.validate_with &validation_block

    request = ActionDispatch::Request.new 'REMOTE_ADDR' => '1.2.3.4'
    token   = ProxyAuthentication::AuthenticationCipher.encode user, request
    ProxyAuthentication::AuthenticationCipher.decode token, request
    ProxyAuthentication.validate_with
  end

  test "call the validation block with the request information" do
    validation_block = lambda {}
    time = Time.now
    ip   = '1.2.3.4'
    arguments = {
      ip:   ip,
      time: Time.at(time.to_i),
      user: user,
    }
    Time.stubs(:now).returns(time)
    validation_block.expects(:call).with(ip, arguments)
    ProxyAuthentication.validate_with &validation_block

    request = ActionDispatch::Request.new 'REMOTE_ADDR' => ip
    token   = ProxyAuthentication::AuthenticationCipher.encode user, request
    ProxyAuthentication::AuthenticationCipher.decode token, request
    ProxyAuthentication.validate_with
  end

  test "returns nil if the validation block return false" do
    validation_block = lambda { |*| false }
    ProxyAuthentication.validate_with &validation_block

    request = ActionDispatch::Request.new 'REMOTE_ADDR' => '1.2.3.4'
    token   = ProxyAuthentication::AuthenticationCipher.encode user, request
    decoded = ProxyAuthentication::AuthenticationCipher.decode token, request
    ProxyAuthentication.validate_with

    assert_nil decoded
  end

  test "returns something if the validation block return true" do
    validation_block = lambda { |*| true }
    ProxyAuthentication.validate_with &validation_block

    request = ActionDispatch::Request.new 'REMOTE_ADDR' => '1.2.3.4'
    token   = ProxyAuthentication::AuthenticationCipher.encode user, request
    decoded = ProxyAuthentication::AuthenticationCipher.decode token, request
    ProxyAuthentication.validate_with

    assert_not_nil decoded
  end

  private

  def user
    @user = User.new 1, 'User', 'user@example.com'
  end

end

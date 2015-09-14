require 'test_helper'

class CipherTest < ActiveSupport::TestCase

  test "data remains the same, but converted to strings" do
    data  = [ 1, 'A', true ]
    token = ProxyAuthentication::Cipher.encode_data_as_url_token data
    assert_equal data.map(&:to_s), ProxyAuthentication::Cipher.decode_data_from_url_token(token)
  end

  test "returns nil if an invalid base64 token is provided" do
    assert_nil ProxyAuthentication::Cipher.decode_data_from_url_token('invalid base64 token')
  end

  test "returns nil if the token's signature is incorrect" do
    data  = [ 1, 2, 3 ] + [ 'invalid signature' ]
    token = Base64.urlsafe_encode64 data.join("\n")
    assert_nil ProxyAuthentication::Cipher.decode_data_from_url_token(token)
  end

end

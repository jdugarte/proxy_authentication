require 'proxy_authentication/cipher'

module ProxyAuthentication

  module AuthenticationCipher

    extend self

    def encode user, request = nil
      data = request_info(request) << user.to_authentication_hash.to_json
      Cipher.encode_data_as_url_token data
    end

    def decode token, request = nil
      data = Cipher.decode_data_from_url_token token
      return nil if data.nil? || !valid_request?(data, request)
      extract_user data.last
    end

    private

    def request_info request
      [
        ip(request.try(:remote_ip)),
        Time.now.to_i,
      ]
    end

    # TODO: add validation for the time of the request
    # e.g. only consider a request valid if it was generated in the last 15 minutes
    def valid_request? data, request
      return true if request.nil?
      return validate_with_block(data, request) if ProxyAuthentication.validate_with_block.present?
      ip(request.remote_ip) == ip(data.first)
    end

    def ip value
      return 'localhost' if %w[ localhost 127.0.0.1 ::1 ].include?(value)
      value
    end

    def extract_user data
      hash = JSON.parse data
      klass = ProxyAuthentication.user_class.to_s.classify.constantize
      klass.from_authentication_hash hash
    end

    def validate_with_block data, request
      arguments = {
        ip:   data.first,
        time: Time.at(data.second.to_i),
        user: extract_user(data.last),
      }
      ProxyAuthentication.validate_with_block.call ip(request.remote_ip), arguments
    end

  end

end

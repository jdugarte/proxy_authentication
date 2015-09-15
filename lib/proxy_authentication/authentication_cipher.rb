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
      return nil if data.nil?

      return nil if request.present? && !valid_request?(data, request)

      extract_user data.last
    end

    private

    def request_info request
      [
        ip(request.try(:remote_ip)),
        Time.now.to_i,
      ]
    end

    def valid_request? data, request
      ip(request.remote_ip) == ip(data.first)
      # TODO: add validation for the time of the request
      # e.g. only consider a request valid if it was generated in the last 15 minutes
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

  end

end

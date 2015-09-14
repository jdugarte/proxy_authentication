module ProxyAuthentication

  module Cipher

    extend self

    def encode_data_as_url_token data, separator = "\n"
      data   = data.join separator
      string = [ data, signature_for(data) ].join separator
      Base64.urlsafe_encode64 string
    end

    def decode_data_from_url_token token_base64, separator = "\n"
      raw_data = decode64 token_base64
      return nil if raw_data.nil?

      data = raw_data.split separator
      actual_signature   = data.pop
      expected_signature = signature_for data.join(separator)
      return nil if actual_signature != expected_signature

      data
    end

    private

    def signature_for string
      OpenSSL::HMAC.hexdigest OpenSSL::Digest::SHA1.new, secret_key, string
    end

    def decode64 token_base64
      Base64.urlsafe_decode64 token_base64
    rescue ArgumentError => exception
      return nil if exception.message =~ /invalid base64/
      raise exception
    end

    def secret_key
      ProxyAuthentication.secret_key || Rails.application.secrets.secret_key_base
    end

  end

end

# Backport Base64.urlsafe_[en|de]code64 methods to ruby 1.8
# https://gist.github.com/phallstrom/1397972
if RUBY_VERSION < '1.9'
  begin
    require 'base64'
  rescue LoadError
  end

  if defined? ::Base64
    module ::Base64
      def self.urlsafe_encode64(bin)
        [bin].pack("m0").tr("+/", "-_")
      end
      def self.urlsafe_decode64(str)
        str.tr("-_", "+/").unpack("m0").first
      end
    end
  end
end

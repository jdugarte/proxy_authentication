require 'proxy_authentication/helpers'
require 'proxy_authentication/authentication_cipher'

module ProxyAuthentication

  mattr_accessor :user_class
  @@user_class = 'User'

  mattr_accessor :redirect_to_if_authentication_failed
  @@redirect_to_if_authentication_failed = nil

  mattr_accessor :secret_key
  @@secret_key = nil

  class << self

    def setup
      setup_warden
      include_helpers
      yield self if block_given?
    end

    private

    def setup_warden
      insert_warden_middleware
      define_warden_strategy
    end

    def insert_warden_middleware
      Rails.configuration.middleware.insert_before ActionDispatch::ParamsParser, Warden::Manager do |manager|
        manager.default_strategies :proxy_authentication_via_token
        manager.serialize_into_session { |user| ProxyAuthentication::AuthenticationCipher.encode user }
        manager.serialize_from_session { |hash| ProxyAuthentication::AuthenticationCipher.decode hash }
      end
    end

    def define_warden_strategy
      Warden::Strategies.add(:proxy_authentication_via_token) do

        def valid?
          params['u'].present? && env['action_controller.instance'].present?
        end

        def authenticate!
          rails_request = env['action_controller.instance'].request
          user = ProxyAuthentication::AuthenticationCipher.decode params['u'].to_s, rails_request
          user.present? ? success!(user) : fail
        end

      end
    end

    def include_helpers
      ApplicationController.send :include, ::ProxyAuthentication::Helpers
    end

  end

end

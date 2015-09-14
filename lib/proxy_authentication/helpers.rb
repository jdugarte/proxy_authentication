module ProxyAuthentication

  module Helpers

    def self.included mod
      mod.helper_method :current_user, :user_signed_in?
    end

    def current_user
      @current_user ||= warden.user
    end

    def user_signed_in?
      !!current_user
    end

    private

    def authenticate_user_from_token!
      warden.logout if warden.authenticated? && params['u'].present?
      warden.authenticate
      redirect_to ProxyAuthentication.redirect_to_if_authentication_failed if warden.unauthenticated?
    end

    def warden
      request.env['warden']
    end

  end

end

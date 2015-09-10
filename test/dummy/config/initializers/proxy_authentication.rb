ProxyAuthentication.setup do |config|

  config.redirect_to_if_authentication_failed = 'http://www.app-a.com/sign_in'
  config.secret_key = Rails.application.secrets.secret_key_base

end

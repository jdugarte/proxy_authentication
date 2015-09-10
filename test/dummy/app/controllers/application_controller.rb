class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include ProxyAuthentication::Helpers

  before_action :authenticate_user_from_token!

end

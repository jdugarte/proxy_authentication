module ProxyAuthentication

  module TestHelpers

    def self.included base
      base.class_eval do
        setup :setup_controller_for_warden, :warden if respond_to? :setup
      end
    end

    def sign_in user
      warden.instance_variable_get(:@users).delete :default
      warden.session_serializer.store user, :default
    end

    def sign_out
      @controller.instance_variable_set :@current_user, nil
      user = warden.instance_variable_get(:@users).delete :default
      warden.session_serializer.delete :default, user
    end

    private

    # We need to setup the environment variables and the response in the controller
    def setup_controller_for_warden
      @request.env['action_controller.instance'] = @controller
    end

    # Quick access to Warden::Proxy (memoized at setup)
    def warden
      @warden ||= new_warden_proxy
    end

    def new_warden_proxy
      manager = Warden::Manager.new nil, &Rails.application.config.middleware.detect { |m| m.name == 'Warden::Manager'}.block
      @request.env['warden'] = Warden::Proxy.new @request.env, manager
    end

  end

end

# Proxy Authentication

ProxyAuthentication allows two Rails applications to share an authenticated user, through a url token. App A can authenticate a user (using its own authentication system, e.g. Devise), and then generate a link to App B with the encoded user info (in the url token). App B can then validate the request and decode the user info.

There could be multiple applications, each one with its own user authentication scheme, using ProxyAuthentication to authenticate users to a single external application.

## Setup

There are two components to be configured: 1) the application owing the user data and generating the url to an external application, and 2) this external application receiving the request with an authenticated user.

### 1. Common parts

Both applications (the generator of the url, and the receiver of the request) must do:

* Add the gem to the `Gemfile`:

    ```ruby
    gem 'proxy_authentication', :github => 'jdugarte/proxy_authentication'
    ```
    and run the bundle command to install it.

* In your user model, include an instance method called `to_authentication_hash`, to create a hash with the user info you'd like to share between both applications:

    ```ruby
    class User < ActiveRecord::Base

      def to_authentication_hash
        {
            :id    => id,
            :name  => name,
            :email => email,
        }
      end

    end
    ```

* Generate a shared _secret key_ to encrypt the token. This _secret key_ will be used in the configuration of both applications, as explained below.

### 2. Application generating the url

* Add the following line to the end of `config/application.rb`, or to a separate initializer file:

    ```ruby
    ProxyAuthentication.secret_key = 'shared_secret_key'
    ```

* Generate the encoded token with the user and request info:

    ```ruby
    user  = User.find 1
    token = ProxyAuthentication::AuthenticationCipher.encode user, request
    ```

* Generate the url, including the `u` query param with the token:

    ```ruby
    link_to "App B", "http://www.app-b.com?u=#{token}"
    ```

### 3. Application receiving the request

* Add an initializar file (e.g. `config/initializers/proxy_authentication.rb`) with at least the following settings:

    ```ruby
    ProxyAuthentication.setup do |config|
        config.redirect_to_if_authentication_failed = 'http://www.app-a.com/sign_in'
        config.secret_key = 'shared_secret_key'
    end
    ```

* In your user model, include a class method called `from_authentication_hash`, to create a user from the shared user info hash:

    ```ruby
    class User < Struct.new :id, :name, :email

        def self.from_authentication_hash hash
            hash.symbolize_keys!
            hash[:id] = hash[:id].to_i
            User.new *hash.values_at(*User.members)
        end

    end
    ```

* Add a `before_action` to application controller:

    ```ruby
    before_action :authenticate_user_from_token!
    ```

## Configuration

The following settings can be configured in the initializater file (e.g. `config/initializers/proxy_authentication.rb`):

| Key | Description | Default |
| --- |-------------| --------|
| user_class                           | The name of the class representing the user      | 'User' |
| redirect_to_if_authentication_failed | A URL to redirect to if the authentication fails | nil    |
| secret_key                           | The key used to encrypt the token                | nil    |
| validate_with                        | Block used to perform the request validation. See _Validation block_ below for details | nil |

### Validation block

In your initializer you can specify a block to perform the validation of the request. This block will receive two arguments: the first one is the current IP address, and the second is a hash containing the request information (ip, time, and user):

```ruby
ProxyAuthentication.setup do |config|
    ...

    config.validate_with do |ip, arguments|
      return true if arguments[:user].name == "Superuser"
      ip == arguments[:ip] && arguments[:time] > 15.minutes.ago
    end
end
```

## Helpers

To verify if a user is signed in, use the following helper:

```ruby
user_signed_in?
```

For the current signed-in user, this helper is available:

```ruby
current_user
```

## Test helpers

ProxyAuthentication provides a couple of helpers for controller tests. To use them, you need to include `ProxyAuthentication::TestHelpers` to `test/test_helper.rb`:

```ruby
class ActionController::TestCase
  include ProxyAuthentication::TestHelpers
end
```

Now you can do in your controller tests:

```ruby
sign_in @user
sign_out
```

## Compatibility/Requirements

This gem has been tested and is known to work with Rails 2.3 and 4, and Warden 1.2, using Ruby 1.8 and 2.0.

## Credits

* The main idea for this gem came from [Mina Naguib](https://github.com/minaguib).
* It was developed as part of a project that originally used [Devise](https://github.com/plataformatec/devise), so it was supposed to mimic a minimal Devise API (current_user, user_signed_in?, test helpers, etc.)
* The controller test helpers use some of [Kentaro Imai's code](http://kentaroimai.com/articles/1-controller-test-helpers-for-warden) for stubbing Warden.
* The backport of Base64.urlsafe_[en|de]code64 methods to ruby 1.8 is by [Philip Hallstrom](https://gist.github.com/phallstrom/1397972)

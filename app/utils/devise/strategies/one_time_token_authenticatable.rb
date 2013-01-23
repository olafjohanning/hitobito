require 'devise/strategies/token_authenticatable'

module Devise
  module Strategies
    # Strategy for signing in a user one single time, based on a authenticatable token.
    # All you need to do is to pass the params in the URL:
    #
    #   http://myapp.example.com/?ontime_token=SECRET
    #
    class OneTimeTokenAuthenticatable < TokenAuthenticatable

      def authenticate!
        resource = mapping.to.find_for_authentication(:reset_password_token => authentication_hash[authentication_keys.first])
        return fail(:invalid_token) unless resource

        success = validate(resource) do
          resource.reset_password_period_valid?
        end
        
        if success
          resource.clear_reset_password_token!
          success!(resource)
        end
      end

    private

      # Overwrite authentication keys to use token_authentication_key.
      def authentication_keys
        @authentication_keys ||= [:onetime_token]
      end
    end
  end
end

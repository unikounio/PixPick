# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      auth = request.env['omniauth.auth']
      @user = User.from_omniauth(auth)

      if @user.persisted?
        request.env['devise.mapping'] = Devise.mappings[:user]
        store_tokens(auth.credentials)

        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
      else
        redirect_to root_path, alert: '認証に失敗しました。もう一度お試しください。'
      end
    end

    def failure
      error = request.env['omniauth.error']
      error_type = request.env['omniauth.error.type']
      logger.error "OmniAuth認証失敗: #{error.message} (Type: #{error_type})"

      redirect_to root_path, alert: '認証に失敗しました。もう一度お試しください。'
    end

    private

    def store_tokens(credentials)
      session[:access_token] = credentials.token
      session[:refresh_token] = credentials.refresh_token
      session[:token_expires_at] = credentials.expires_at
    end
  end
end

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      redirect_to root_path, alert: "認証に失敗しました。もう一度お試しください。"
    end
  end

  def failure
    error = request.env["omniauth.error"]
    error_type = request.env["omniauth.error.type"]
    Rails.logger.error "OmniAuth認証失敗: #{error.message} (Type: #{error_type})"

    redirect_to root_path, alert: "認証に失敗しました。もう一度お試しください。"
  end
end

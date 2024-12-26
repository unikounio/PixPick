# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      auth = request.env['omniauth.auth']
      @user = User.from_omniauth(auth)

      if @user.persisted?
        process_successful_authentication
      else
        set_flash_message(:alert, :failure, kind: 'Google') if is_navigational_format?
        redirect_to root_path
      end
    end

    def failure
      error = request.env['omniauth.error']
      error_type = request.env['omniauth.error.type']
      logger.error "OmniAuth認証失敗: #{error.message} (Type: #{error_type})"
      set_flash_message(:alert, :failure, kind: 'Google') if is_navigational_format?
      redirect_to root_path
    end

    private

    def process_successful_authentication
      request.env['devise.mapping'] = Devise.mappings[:user]
      participation_result =
        (participate_contest(@user) if session[:contest_id].present?)
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
      sign_in_and_redirect @user, participation_result
    end

    def participate_contest(user)
      @contest_id = session.delete(:contest_id)

      if Participant.find_by(user_id: user.id, contest_id: @contest_id)
        flash[:participation_alert] = 'このコンテストは既に参加済みです。'
        return true
      end

      contest = Contest.find(@contest_id)
      if contest.add_participant(user.id)
        flash[:participation_notice] = 'コンテストに参加しました。'
        true
      else
        flash[:participation_alert] = 'コンテストへの参加に失敗しました。'
        false
      end
    end

    def sign_in_and_redirect(user, participation_result)
      sign_in user
      redirect_to after_sign_in_path_for(@user, participation_result)
    end

    def after_sign_in_path_for(user, participation_result)
      if participation_result
        contest_path(@contest_id)
      elsif user.contests.count.zero?
        new_contest_path
      elsif user.contests.count == 1
        contest_path(user.contests.first)
      else
        user_contests_path(user)
      end
    end
  end
end

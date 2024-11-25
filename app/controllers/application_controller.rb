# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :set_recent_contests
  before_action :set_selected_contest

  private

  def ensure_valid_access_token!
    return if session[:token_expires_at].nil? || !current_user.token_expired?(session[:token_expires_at])

    result = current_user.request_token_refresh(session[:refresh_token])
    if result.present?
      store_access_token(result)
    else
      sign_out current_user
      redirect_to root_path, alert: t('activerecord.errors.messages.failed_to_refresh_token')
    end
  end

  def store_access_token(result)
    session[:access_token] = result['access_token']
    session[:token_expires_at] = Time.current + result['expires_in'].seconds
  end

  def set_selected_contest
    contest_id = params[:contest_id] || params[:id]
    return unless user_signed_in? && contest_id.present?

    @selected_contest_name = Rails.cache.fetch("contest_name_#{contest_id}", expires_in: 12.hours) do
      Contest.find(contest_id)&.name
    end
  end

  def set_recent_contests
    @recent_contests = if user_signed_in?
                         current_user.contests.order(updated_at: :desc).limit(4)
                       else
                         []
                       end
  end
end

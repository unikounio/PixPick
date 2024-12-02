# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :set_recent_contests
  before_action :set_selected_contest

  private

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

  def append_turbo_toast(type, message)
    turbo_stream.append('toast',
                        partial: 'shared/toast',
                        locals: { toasts: [{ type:, message: }] })
  end
end

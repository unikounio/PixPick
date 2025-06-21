# frozen_string_literal: true

class ContestsController < ApplicationController
  before_action :authorize_participant, only: %i[show ranking edit update invite destroy]

  def index
    @contests = current_user.contests
  end

  def show
    @entries_with_score = @contest.entries_with_score_for(current_user)
  end

  def ranking
    @rankings = Ranking.calculate(@contest.sort_entries_by_total_score)

    render :show
  end

  def new
    @contest = Contest.new
    @contests = current_user.contests
  end

  def edit
    @is_editing_contest = true
    @users = User.eager_load(:participants).where(participants: { contest_id: @contest.id })
  end

  def create
    @contest = current_user.contests.new(contest_params)

    if @contest.save_with_participant(current_user.id)
      redirect_to new_contest_entry_path(@contest),
                  notice: t('activerecord.notices.messages.create', model: t('activerecord.models.contest'))
    else
      log_and_render_toast('保存')
    end
  end

  def update
    @users = @contest.users
    if no_changes_to_update?
      render turbo_stream: append_turbo_toast(:error, '更新する項目がありません')
      return
    end

    if @contest.update(contest_params)
      updated_message = @contest.determine_updated_message
      render turbo_stream: append_turbo_toast(:success, "#{updated_message}を更新しました")
    else
      log_and_render_toast('更新')
    end
  end

  def invite
    @invite_url = new_contest_participant_url(contest_id: params[:id], token: @contest.invitation_token)
  end

  def destroy
    @contest.destroy!
    redirect_to user_contests_path(current_user), notice: 'コンテストが削除されました。'
  end

  private

  def authorize_participant
    unless Participant.exists?(contest_id: @contest.id, user_id: current_user.id)
      redirect_to root_path, alert: '指定されたコンテストに参加していません。'
    end
  end

  def contest_params
    params.expect(contest: %i[name deadline])
  end

  def log_and_render_toast(action_name)
    error_messages = @contest.errors.full_messages

    Rails.logger.error "コンテストの#{action_name}に失敗: #{error_messages.join(', ')}"

    render turbo_stream: error_messages.map { |message| append_turbo_toast(:error, message) }
  end

  def no_changes_to_update?
    @contest.name == contest_params[:name] && @contest.deadline == Time.zone.parse(contest_params[:deadline])
  end
end

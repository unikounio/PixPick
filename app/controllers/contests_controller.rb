# frozen_string_literal: true

class ContestsController < ApplicationController
  def index
    @contests = current_user.contests
  end

  def show
    @entry_scores = @contest.entry_scores_for(current_user)
    @uploading_entry_counts = @contest.uploading_entry_counts(session)
  end

  def ranking
    entries_with_scores = @contest.entries
                                  .with_total_scores
                                  .order(total_score: :desc, id: :asc)

    @ranked_entries = []
    current_rank = 0
    previous_score = nil

    entries_with_scores.each_with_index do |entry, index|
      if entry.total_score != previous_score
        current_rank = index + 1
        previous_score = entry.total_score
      end

      @ranked_entries << {
        rank: current_rank,
        entry_id: entry.id,
        total_score: entry.total_score
      }
    end

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
      log_and_render_toast
    end
  end

  def update
    @users = @contest.users
    if no_changes_to_update?
      render turbo_stream: append_turbo_toast(:error, '更新する項目がありません')
      return
    end

    if @contest.update(contest_params)
      updated_message = determine_updated_message
      render turbo_stream: append_turbo_toast(:success, "#{updated_message}を更新しました")
    else
      log_and_render_toast
    end
  end

  def invite
    @invite_url = new_contest_participant_url(contest_id: params[:id], token: @contest.invitation_token)
  end

  def destroy
    if @contest.destroy
      redirect_to user_contests_path(current_user), notice: 'コンテストが削除されました。'
    else
      log_and_render_toast
    end
  end

  private

  def contest_params
    params.require(:contest).permit(:name, :deadline)
  end

  def log_and_render_toast
    Rails.logger.error "コンテストの保存に失敗: #{@contest.errors.full_messages.join(', ')}"

    turbo_streams = @contest.errors.full_messages.map do |message|
      append_turbo_toast(:error, message)
    end

    render turbo_stream: turbo_streams
  end

  def no_changes_to_update?
    @contest.name == contest_params[:name] && @contest.deadline == Time.zone.parse(contest_params[:deadline])
  end

  def determine_updated_message
    if @contest.saved_change_to_name? && @contest.saved_change_to_deadline?
      'コンテスト名と投票期日'
    elsif @contest.saved_change_to_name?
      'コンテスト名'
    elsif @contest.saved_change_to_deadline?
      '投票期日'
    end
  end
end

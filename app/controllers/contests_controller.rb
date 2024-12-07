# frozen_string_literal: true

class ContestsController < ApplicationController
  include GoogleApiActions

  before_action :ensure_valid_access_token!, only: %i[show create update]
  before_action :set_contest, only: %i[show edit update invite destroy]
  before_action :set_drive_service, only: %i[show create update]

  def index
    @contests = current_user.contests
  end

  def show
    entries = @contest.entries.order(created_at: :desc)
    @thumbnail_data = entries.map do |entry|
      thumbnail_link = @drive_service.get_thumbnail_link(entry.drive_file_id)
      score = current_user.votes.find_by(entry_id: entry.id)&.score
      [thumbnail_link, entry.id, score]
    end
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
    folder_id, permission_id = setup_drive_folder

    if folder_id.present? && @contest.save_contest_and_create_participant(folder_id, permission_id, current_user.id)
      redirect_to new_contest_entry_path(@contest),
                  notice: t('activerecord.notices.messages.create', model: t('activerecord.models.contest'))
    else
      redirect_with_failure
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
      @drive_service.update_file_name(@contest.drive_file_id, @contest.name)

      render turbo_stream: append_turbo_toast(:success, "#{updated_message}を更新しました")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def invite
    @invite_url = new_contest_participant_url(contest_id: params[:id], token: @contest.invitation_token)
  end

  def destroy
    @contest.destroy
    redirect_to user_contests_path(current_user), notice: 'コンテストが削除されました。'
  end

  private

  def contest_params
    params.require(:contest).permit(:name, :deadline)
  end

  def set_contest
    @contest = Contest.find(params[:id])
  end

  def redirect_with_failure
    @contests = current_user.contests
    render :new, status: :unprocessable_entity
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

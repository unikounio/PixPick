# frozen_string_literal: true

class ContestsController < ApplicationController
  before_action :set_contest, only: %i[show edit destroy]
  before_action :set_drive_service, only: %i[show create]
  before_action :ensure_valid_access_token!
  def index
    @contests = current_user.contests
  end

  def show
    entries = @contest.entries.order(created_at: :desc)
    @thumbnail_links = entries.map { |entry| @drive_service.get_thumbnail_link(entry.drive_file_id) }
  end

  def new
    @contest = Contest.new
    @contests = current_user.contests
  end

  def edit; end

  def create
    @contest = current_user.contests.new(contest_params)
    folder_id, permission_id = setup_drive_folder

    if folder_id.present? && save_contest_and_create_participant(folder_id, permission_id)
      redirect_to new_contest_entry_path(@contest),
                  notice: t('activerecord.notices.messages.create', model: t('activerecord.models.contest'))
    else
      redirect_with_failure
    end
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

  def set_drive_service
    @drive_service = GoogleDriveService.new(session[:access_token])
  end

  def setup_drive_folder
    folder_id = @drive_service.create_folder(@contest.name)

    if folder_id.present?
      permission_id = @drive_service.share_file(folder_id)
      return nil if permission_id.nil?
    end

    [folder_id, permission_id]
  end

  def save_contest_and_create_participant(folder_id, permission_id)
    ActiveRecord::Base.transaction do
      @contest.drive_file_id = folder_id
      @contest.drive_permission_id = permission_id
      @contest.save!
      @contest.participants.create!(user: current_user)
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def redirect_with_failure
    @contests = current_user.contests
    render :new, status: :unprocessable_entity
  end
end

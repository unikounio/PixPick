# frozen_string_literal: true

class ContestsController < ApplicationController
  before_action :set_contest, only: %i[show edit destroy]
  before_action :ensure_valid_access_token!
  def index
    @contests = current_user.contests
  end

  def show
    entries = @contest.entries
    access_token = session[:access_token]
    base_urls = entries.map do |entry|
      entry.refresh_base_url(access_token) if Time.current > entry.base_url_updated_at + 60.minutes
      entry.base_url
    end
    @entry_photos = Entry.get_photo_images(base_urls, access_token)
  end

  def new
    @contest = Contest.new
    @contests = current_user.contests
  end

  def edit; end

  def create
    @contest = current_user.contests.new(contest_params)
    folder_id = setup_drive_folder

    if folder_id.present? && save_contest_and_create_participant(folder_id)
      redirect_to new_contest_entry_path(@contest),
                  notice: t('activerecord.notices.messages.create', model: t('activerecord.models.contest'))
    else
      redirect_with_failure(folder_id)
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

  def setup_drive_folder
    drive_service = GoogleDriveService.new(session[:access_token])
    drive_service.create_folder(@contest.name)
  end

  def save_contest_and_create_participant(folder_id)
    ActiveRecord::Base.transaction do
      @contest.drive_file_id = folder_id
      @contest.save!
      @contest.participants.create!(user: current_user)
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def redirect_with_failure(folder_id)
    Rails.logger.error 'Google Driveフォルダ作成に失敗しました' if folder_id.nil?
    @contests = current_user.contests
    render :new, status: :unprocessable_entity
  end
end

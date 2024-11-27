# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :set_contest, only: %i[show new create]
  before_action :ensure_valid_access_token!, only: %i[new]

  def show
    @entry = Entry.find(params[:id])
    render partial: 'entries/show', formats: [:html]
  end

  def image_proxy
    entry = Entry.find(params[:id])
    cache_key = "entry_image_#{entry.id}"

    image_data, mime_type = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      drive_service = GoogleDriveService.new(session[:access_token])
      drive_service.download_file(entry.drive_file_id)
    end

    if image_data
      send_data image_data, type: mime_type, disposition: 'inline', cache_control: 'public, max-age=3600'
    else
      head :not_found
    end
  end

  def new
    @folder_id = @contest.drive_file_id
    @access_token = session[:access_token]
  end

  def create
    files = files_params[:files]

    if files.blank?
      render json: { error: 'ファイルが見つかりません' }, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      upload_and_create_entries!(files, @contest)
      render json: { redirect_url: contest_path(@contest) }, status: :ok
    rescue StandardError => e
      Rails.logger.error("ファイルの処理注に次のエラーが発生: #{e.message}")
      render json: { error: 'ファイルの処理中にエラーが発生しました' }, status: :unprocessable_entity
    end
  end

  private

  def files_params
    params.permit(files: [])
  end

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def upload_and_create_entries!(files, contest)
    files.each do |file|
      drive_file_id, permission_id = upload_to_google_drive(file, contest)

      Entry.create!(
        user: current_user,
        contest: contest,
        drive_file_id: drive_file_id,
        drive_permission_id: permission_id
      )
    end
  end

  def upload_to_google_drive(file, contest)
    drive_service = GoogleDriveService.new(session[:access_token])

    drive_file_id = drive_service.upload_file(file, contest.drive_file_id)
    raise 'Google Driveへのアップロードに失敗' if drive_file_id.nil?

    permission_id = drive_service.share_file(drive_file_id)
    raise 'Google Drive共有設定に失敗' if permission_id.nil?

    [drive_file_id, permission_id]
  end
end

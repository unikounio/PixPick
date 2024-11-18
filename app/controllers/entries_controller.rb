# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :ensure_valid_access_token!, only: %i[new]

  def new
    @contest = Contest.find(params[:contest_id])
    @folder_id = @contest.drive_file_id
    @access_token = session[:access_token]
  end

  def create
    files = files_params[:files]
    contest = Contest.find(params[:contest_id])

    if files.blank?
      render json: { error: 'ファイルが見つかりません' }, status: :unprocessable_entity
      return
    end

    begin
      upload_and_create_entries!(files, contest)
      render json: { redirect_url: contest_path(contest) }, status: :ok
    rescue StandardError => e
      Rails.logger.error("ファイルの処理注に次のエラーが発生: #{e.message}")
      render json: { error: 'ファイルの処理中にエラーが発生しました' }, status: :unprocessable_entity
    end
  end

  private

  def files_params
    params.permit(files: [])
  end

  def upload_and_create_entries!(files, contest)
    files.each do |file|
      drive_file_id = upload_to_google_drive(file, contest)
      raise 'Google Driveへのアップロードに失敗' if drive_file_id.nil?

      Entry.create!(
        user: current_user,
        contest: contest,
        drive_file_id: drive_file_id
      )
    end
  end

  def upload_to_google_drive(file, contest)
    drive_service = GoogleDriveService.new(session[:access_token])
    drive_service.upload_file(file, contest.drive_file_id)
  end
end

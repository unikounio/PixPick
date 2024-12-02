# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :set_contest, only: %i[show new create destroy]
  before_action :set_entry, only: %i[show image_proxy destroy]
  before_action :set_drive_service, only: %i[image_proxy create destroy]
  before_action :ensure_valid_access_token!, only: %i[new]

  def show
    @previous_entry = @entry.contest.entries.where('id > ?', @entry.id).order(id: :asc).first
    @next_entry = @entry.contest.entries.where(id: ...@entry.id).order(id: :desc).first
    render partial: 'entries/show', formats: [:html]
  end

  def image_proxy
    cache_key = "entry_image_#{@entry.id}"

    image_data, mime_type = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      original_data, mime_type = @drive_service.download_file(@entry.drive_file_id)

      resized_data = resize_and_convert_image(original_data, mime_type, 600, 400)
      [resized_data, mime_type]
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

  def destroy
    authorize_user!

    if @drive_service.delete_file(@entry.drive_file_id) && @entry.destroy
      render turbo_stream: [
        turbo_stream.remove("entry_#{params[:id]}"),
        turbo_stream.append('toast', partial: 'shared/toast',
                            locals: { toasts: [{ type: :success, message: 'エントリーが削除されました。' }] })
      ]
    else
      render turbo_stream: turbo_stream.append('toast', partial: 'shared/toast',
                                                        locals: { toasts: [{ type: :error,
                                                                             message: 'エントリーの削除に失敗しました。' }] })
    end
  end

  private

  def files_params
    params.permit(files: [])
  end

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def set_entry
    @entry = Entry.find(params[:id])
  end

  def set_drive_service
    @drive_service = GoogleDriveService.new(session[:access_token])
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
    drive_file_id = @drive_service.upload_file(file, contest.drive_file_id)
    raise 'Google Driveへのアップロードに失敗' if drive_file_id.nil?

    permission_id = @drive_service.share_file(drive_file_id)
    raise 'Google Drive共有設定に失敗' if permission_id.nil?

    [drive_file_id, permission_id]
  end

  def resize_and_convert_image(image_data, mime_type, width, height)
    format = mime_type_to_format(mime_type) || 'jpg'
    tempfile = create_tempfile(image_data, format)

    begin
      resized_image = ImageProcessing::MiniMagick
                      .source(tempfile.path)
                      .resize_to_fit(width, height)
                      .convert(format)
                      .call

      File.binread(resized_image.path)
    ensure
      tempfile.close!
      tempfile.unlink
    end
  end

  def mime_type_to_format(mime_type)
    case mime_type
    when 'image/jpeg', 'image/jpg' then 'jpg'
    when 'image/png'               then 'png'
    when 'image/webp'              then 'webp'
    else
      Rails.logger.warn "Unsupported MIME type: #{mime_type}"
      nil
    end
  end

  def create_tempfile(image_data, format)
    tempfile = Tempfile.new(['image', ".#{format}"])
    tempfile.binmode
    tempfile.write(image_data.read)
    tempfile.rewind
    tempfile
  end

  def authorize_user!
    return if @entry.user == current_user

    render turbo_stream: turbo_stream.append('toast', partial: 'shared/toast',
                                                      locals: { toasts: [{ type: :error,
                                                                           message: 'このエントリーを削除する権限がありません。' }] })
  end
end

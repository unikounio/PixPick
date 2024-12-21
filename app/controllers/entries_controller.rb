# frozen_string_literal: true

class EntriesController < ApplicationController
  include GoogleApiActions

  before_action :ensure_valid_access_token!, only: %i[image_proxy create destroy]
  before_action :set_entry, only: %i[thumbnail_proxy show image_proxy destroy]
  before_action :set_drive_service, only: %i[thumbnail_proxy image_proxy destroy]

  def thumbnail_proxy
    cache_key = "entry_thumbnail_#{@entry.id}"

    image_data, mime_type = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      thumbnail_link = @drive_service.get_thumbnail_link(@entry.drive_file_id)

      if thumbnail_link.present?
        @drive_service.fetch_thumbnail(thumbnail_link)
      else
        [nil, nil]
      end
    end

    if image_data
      send_data image_data, type: mime_type, disposition: 'inline', cache_control: 'public, max-age=3600'
    else
      head :not_found
    end
  end

  def show
    @previous_entry = @entry.contest.entries.where('id > ?', @entry.id).order(id: :asc).first
    @next_entry = @entry.contest.entries.where(id: ...@entry.id).order(id: :desc).first
    render partial: 'entries/show', formats: [:html]
  end

  def image_proxy
    cache_key = "entry_image_#{@entry.id}"

    image_data, mime_type = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      original_data, mime_type = @drive_service.download_file(@entry.drive_file_id)

      resized_data = EntryResizer.resize_and_convert_image(original_data, mime_type, 400, 400)
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

    error_message = validate_files(files)
    if error_message.present?
      render json: { error: error_message }, status: :unprocessable_entity
      return
    end

    file_data = prepare_file_data(files)
    EntryUploadJob.perform_later(file_data, current_user.id, @contest.id, session[:access_token])

    render json: { redirect_url: contest_path(@contest) }
  end

  def destroy
    authorize_user!

    if @drive_service.delete_file(@entry.drive_file_id) && @entry.destroy
      render turbo_stream: [
        turbo_stream.remove("entry_#{params[:id]}"),
        append_turbo_toast(:success, t('activerecord.notices.messages.delete', model: t('activerecord.models.entry')))
      ]
    else
      render turbo_stream: append_turbo_toast(:error,
                                              t('activerecord.errors.messages.delete',
                                                model: t('activerecord.models.entry')))
    end
  end

  private

  def files_params
    params.permit(files: [])
  end

  def set_entry
    @entry = Entry.find(params[:id])
  end

  def validate_files(files)
    return 'ファイルが見つかりません' if files.blank?

    Entry.validate_mime_type(files)
  end

  def prepare_file_data(files)
    files.map do |file|
      temp_path = Rails.root.join('tmp', file.original_filename)
      File.binwrite(temp_path, file.read)
      { path: temp_path.to_s, name: file.original_filename, content_type: file.content_type }
    end
  end

  def authorize_user!
    return if @entry.user == current_user

    render turbo_stream: append_turbo_toast(:error,
                                            t('activerecord.errors.messages.unauthorized',
                                              model: t('activerecord.models.entry')))
  end
end

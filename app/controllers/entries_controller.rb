# frozen_string_literal: true

class EntriesController < ApplicationController
  include GoogleApiActions

  before_action :ensure_valid_access_token!, only: %i[image_proxy create destroy]
  before_action :set_contest, only: %i[show new create]
  before_action :set_entry, only: %i[thumbnail_proxy show image_proxy destroy]
  before_action :set_drive_service, only: %i[thumbnail_proxy image_proxy create destroy]

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

    if files.blank?
      render json: { error: 'ファイルが見つかりません' }, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      Entry.upload_and_create_entries!(files, current_user, @contest, @drive_service)
      render json: { redirect_url: contest_path(@contest) }, status: :ok
    rescue StandardError => e
      Rails.logger.error("ファイルの処理中に次のエラーが発生: #{e.message}")
      render json: { error: 'ファイルの処理中にエラーが発生しました' }, status: :unprocessable_entity
    end
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

  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def set_entry
    @entry = Entry.find(params[:id])
  end

  def authorize_user!
    return if @entry.user == current_user

    render turbo_stream: append_turbo_toast(:error,
                                            t('activerecord.errors.messages.unauthorized',
                                              model: t('activerecord.models.entry')))
  end
end

# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :set_entry, only: %i[show destroy]

  def show
    @previous_entry = @entry.contest.entries.where('id > ?', @entry.id).order(id: :asc).first
    @next_entry = @entry.contest.entries.where(id: ...@entry.id).order(id: :desc).first
    render partial: 'entries/show', formats: [:html]
  end

  def new; end

  def create
    files = files_params[:files]

    error_message = validate_files(files)
    if error_message.present?
      render json: { error: error_message }, status: :unprocessable_entity
      return
    end

    image_data = prepare_image_data(files)
    session[:"contest_#{@contest.id}_uploading_entry_counts"] = image_data.count

    EntryUploadJob.perform_later(image_data, current_user.id, @contest.id)

    render json: { redirect_url: contest_path(@contest) }
  end

  def status
    redis = Redis.new
    status = redis.get("uploading_#{params[:id]}")

    render plain: status
  end

  def destroy
    authorize_user!

    if @entry.destroy
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

  def prepare_image_data(files)
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

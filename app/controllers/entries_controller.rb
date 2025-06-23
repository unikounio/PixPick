# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :set_entry, only: %i[show destroy]
  before_action :authorize_participant, only: %i[show new create destroy]

  def show
    @previous_entry = @entry.contest.entries.where('id > ?', @entry.id).order(id: :asc).first
    @next_entry = @entry.contest.entries.where(id: ...@entry.id).order(id: :desc).first
    render partial: 'entries/show', formats: [:html]
  end

  def new; end

  def create
    files = files_params[:files]

    if files.size > 10
      render json: { error: 'アップロードできる写真の最大数は10枚です' }, status: :unprocessable_entity
      return
    end

    error_message = validate_files(files)
    if error_message.present?
      render json: { error: error_message }, status: :unprocessable_entity
      return
    end

    files.each do |file|
      Entry.upload_and_create_entries!(file, current_user, @contest)
    end

    render json: { redirect_url: contest_path(@contest) }
  end

  def destroy
    return unless authorize_user!

    @entry.destroy!
    render turbo_stream: [
      turbo_stream.remove("entry_#{params[:id]}"),
      append_turbo_toast(:success, t('activerecord.notices.messages.delete', model: t('activerecord.models.entry')))
    ]
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

  def authorize_user!
    return true if @entry.user == current_user

    render turbo_stream: append_turbo_toast(:error,
                                            t('activerecord.errors.messages.unauthorized',
                                              model: t('activerecord.models.entry')))
    false
  end
end

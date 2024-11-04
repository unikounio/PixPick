# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :ensure_valid_access_token!

  def new
    client = GooglePhotosPickerApiClient.new(session[:access_token])
    @picking_session = client.create_session

    if @picking_session.present?
      Rails.logger.info "PickingSession: #{@picking_session}"
      session[:picking_session_id] = @picking_session['id']
      @polling_url = "https://photospicker.googleapis.com/v1/sessions/#{session[:picking_session_id]}"
      render :new
    else
      redirect_to root_path, alert: t('activerecord.errors.messages.unexpected_error')
    end
  end

  def finish_polling
    entry_params = entry_finish_polling_params
    contest_id = entry_params[:contest_id]
    session_id = session[:picking_session_id]
    client = GooglePhotosPickerApiClient.new(session[:access_token])

    if entry_params[:media_items_set]
      handle_media_items(client, session_id, entry_params[:contest_id])
    else
      delete_picking_session(client, session_id)
      render json: {
        redirect_url: new_contest_entry_path(contest_id),
        alert: t('activerecord.errors.messages.unexpected_error')
      }
    end
  end

  def create
    entry_params = entry_create_params
    entries_attributes = entry_params[:entries_attributes]
    contest_id = entry_params[:contest_id]

    if entries_attributes.present?
      create_entry_and_redirect_contest(entries_attributes, contest_id)
    else
      render json: { redirect_url: new_contest_entry_path(contest_id),
                     alert: t('activerecord.errors.messages.no_photos_to_register') }
    end
  end

  private

  def entry_finish_polling_params
    { media_items_set: params.require(:mediaItemsSet), contest_id: params.require(:contest_id) }
  end

  def entry_create_params
    parsed_attributes = JSON.parse(params.require(:entryAttributes))

    entries_attributes = parsed_attributes.map do |entry_attribute|
      ActionController::Parameters.new(entry_attribute).permit(:media_item_id, :base_url)
    end

    { entries_attributes: entries_attributes, contest_id: params.require(:contest_id) }
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

  def handle_media_items(client, session_id, contest_id)
    media_items, @next_page_token = client.fetch_media_items(session_id)
    @entries_attributes = Entry.extract_ids_and_urls_from_media_items(media_items)
    # rubocop:disable Rails/Pluck
    base_urls = JSON.parse(@entries_attributes).map { |attribute| attribute['base_url'] }
    # rubocop:enable Rails/Pluck
    @photo_thumbnails = Entry.get_photo_images(base_urls, session[:access_token])
    delete_picking_session(client, session_id)

    if @photo_thumbnails.present?
      @contest_id = contest_id
      render turbo_stream: turbo_stream.replace('media_items', partial: 'entries/media_items')
    else
      render json: {
        redirect_url: new_contest_entry_path(contest_id),
        alert: t('activerecord.errors.messages.unexpected_error')
      }
    end
  end

  def delete_picking_session(client, session_id)
    response = client.delete_session(session_id)
    session.delete(:picking_session_id) if response.success? && session[:delete_picking_session].present?
  end

  def create_entry_and_redirect_contest(entries_attributes, contest_id)
    Entry.create_from_entries_attributes(entries_attributes, contest_id, current_user.id)
    render json: { redirect_url: contest_path(contest_id) }
  end
end

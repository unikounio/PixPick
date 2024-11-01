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
    media_items_set = params[:mediaItemsSet]
    session_id = session[:picking_session_id]
    client = GooglePhotosPickerApiClient.new(session[:access_token])

    if media_items_set
      handle_media_items(client, session_id)
    else
      delete_picking_session(client, session_id)
      redirect_to new_contest_entry_path, alert: t('activerecord.errors.messages.unexpected_error')
    end
  end

  def create
    if params[:baseUrls].present?
      base_urls = JSON.parse(params[:baseUrls])
      handle_base_urls(base_urls)
    else
      render json: { redirect_url: new_contest_entry_path(params[:contest_id]),
                     alert: t('activerecord.errors.messages.no_photos_to_register') }
    end
  end

  private

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

  def handle_media_items(client, session_id)
    media_items, @next_page_token = client.fetch_media_items(session_id)
    @base_urls = Entry.extract_base_urls(media_items)
    @photo_thumbnails = Entry.get_photo_images(@base_urls, session[:access_token], 256, 256)
    delete_picking_session(client, session_id)

    if @photo_thumbnails.present?
      @contest_id = params[:contest_id]
      render turbo_stream: turbo_stream.replace('media_items', partial: 'entries/media_items')
    else
      redirect_to new_contest_entry_path, alert: t('activerecord.errors.messages.unexpected_error')
    end
  end
  def delete_picking_session(client, session_id)
    response = client.delete_session(session_id)
    session.delete(:picking_session_id) if response.success? && session[:delete_picking_session].present?
  end

  def handle_base_urls(base_urls)
    Entry.create_from_base_urls(base_urls, params[:contest_id], current_user.id)
    render json: { redirect_url: contest_path(params[:contest_id]) }
  end
end

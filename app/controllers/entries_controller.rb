# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :ensure_valid_access_token!

  def new
    response = request_picker_api('v1/sessions', :post)

    if response.success?
      @picking_session = JSON.parse(response.body)
      Rails.logger.info "PickingSession: #{@picking_session}"
      session[:picking_session_id] = @picking_session['id']

      @polling_url = "https://photospicker.googleapis.com/v1/sessions/#{session[:picking_session_id]}"

      render :new
    else
      Rails.logger.error "PickingSessionの作成に失敗: #{response.body}"
      redirect_to root_path, alert: 'セッションの作成に失敗しました。再試行してください。'
      return
    end
  end

  def finish_polling
    media_items_set = params[:mediaItemsSet]
    Rails.logger.info "Polling session finished"
    session_id = session[:picking_session_id]

    if media_items_set
      session[:selected_items], session[:next_page_token] = list_selected_media_items(session_id)
      Rails.logger.info "selected_items: #{session[:selected_items]}"
      Rails.logger.info "next_page_token: #{session[:next_page_token]}"

      @photos = session[:selected_items].map do |item|
        response = Faraday.get("#{item['mediaFile']['baseUrl']}=w256-h256") do |req|
          req.headers['Authorization'] = "Bearer #{session[:access_token]}"
        end
        response.body
      end

      delete_picking_session(session_id)
      if @photos.present?
        render turbo_stream: turbo_stream.replace("selected_items", partial: "entries/selected_items", locals: { photos: @photos })
      else
        redirect_to new_contest_entry_path, alert: "予期せぬエラーが発生しました。再度お試しください。"
      end
    else
      delete_picking_session(session_id)
      redirect_to new_contest_entry_path, alert: "予期せぬエラーが発生しました。再度お試しください。"
    end
  end

  def create
    selected_items = session[:selected_items]

    if selected_items.present?
      selected_items.each do |item|
        Entry.create!(
          photo_url: item['mediaFile']['baseUrl'],
          contest_id: params[:contest_id],
          user_id: current_user.id
        )
      end

      session.delete(:selected_items)
      redirect_to contest_path(params[:contest_id])
    else
      redirect_to new_contest_entry_path(params[:contest_id]), alert: '登録する写真がありません。もう1度やり直してください。'
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

  def request_picker_api(end_point, method = :get, params = nil)
    allowed_methods = %i[get post delete]
    raise ArgumentError, "HTTP method #{method} is not allowed." unless allowed_methods.include?(method)

    connection = Faraday.new(url: 'https://photospicker.googleapis.com')

    connection.public_send(method, end_point) do |req|
      req.headers['Authorization'] = "Bearer #{session[:access_token]}"
      req.params = params if method == :get && params.present?
    end
  end

  def delete_picking_session(session_id)
    response = request_picker_api("v1/sessions/#{session_id}", :delete)

    if response.success?
      Rails.logger.info "セッション #{session_id} を正常に削除しました。"
      session.delete(:picking_session_id) if session[:delete_picking_session].present?
    else
      Rails.logger.error "セッション削除に失敗: #{response.body}"
    end
  end

  def list_selected_media_items(session_id)
    response = request_picker_api("v1/mediaItems", :get, { sessionId: session_id })
    if response.success?
      response_body = JSON.parse(response.body)
      [response_body['mediaItems'], response_body['nextPageToken']]
    else
      Rails.logger.error "メディアアイテムの取得に失敗: #{response.body}"
      [nil, nil]
    end
  end
end

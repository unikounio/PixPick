# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :ensure_valid_access_token!

  def new
    response = request_picker_api('v1/sessions', :post)

    if response.success?
      @picking_session = JSON.parse(response.body)
      session[:picking_session_id] = @picking_session['id']

      @polling_url = "https://photospicker.googleapis.com/v1/sessions/#{session[:picking_session_id]}"

      render :new
    else
      Rails.logger.error "PickingSessionの作成に失敗: #{response.body}"
      redirect_to root_path, alert: 'セッションの作成に失敗しました。再試行してください。'
      return
    end
  end

  private

  def ensure_valid_access_token!
    return if session[:token_expires_at].nil? || !current_user.token_expired?(session[:token_expires_at])

    result = current_user.request_token_refresh(session[:refresh_token])
    if result
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
    else
      Rails.logger.error "セッション削除に失敗: #{response.body}"
    end
  end
end

# frozen_string_literal: true

class PhotosController < ApplicationController
  before_action :ensure_valid_access_token!
  def index
    @photos = fetch_photos(session[:access_token])

    render :'photos/index'
  end

  private

  def ensure_valid_access_token!
    return unless current_user.token_expired?(session[:token_expires_at])

    result = current_user.request_token_refresh(session[:refresh_token])
    if result
      session[:access_token] = result['access_token']
      session[:token_expires_at] = Time.current + result['expires_in'].seconds
    else
      sign_out_and_redirect
    end
  end

  def sign_out_and_redirect
    sign_out current_user
    redirect_to root_path, notice: 'アクセストークンの更新に失敗しました。再度ログインしてください。'
  end

  def fetch_photos(access_token)
    response = make_request(access_token)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)['mediaItems'].pluck('baseUrl')
    else
      Rails.logger.error "Google Photos APIからの写真取得に失敗: #{response.body}"
      []
    end
  end

  def make_request(access_token)
    uri = URI('https://photoslibrary.googleapis.com/v1/mediaItems')
    params = { pageSize: 100 }
    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{access_token}"

    http.request(request)
  end
end

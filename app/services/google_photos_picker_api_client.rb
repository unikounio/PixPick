# frozen_string_literal: true

class GooglePhotosPickerApiClient
  BASE_URL = 'https://photospicker.googleapis.com/v1'

  def initialize(access_token)
    @access_token = access_token
    @connection = Faraday.new(url: BASE_URL) do |conn|
      conn.headers['Authorization'] = "Bearer #{@access_token}"
    end
  end

  def create_session
    response = @connection.post('sessions')
    if response.success?
      JSON.parse(response.body)
    else
      Rails.logger.error "PickingSessionの作成に失敗: #{response.body}"
      nil
    end
  end

  def fetch_media_items(session_id)
    response = @connection.get('mediaItems', { sessionId: session_id })
    if response.success?
      response_body = JSON.parse(response.body)
      [response_body['mediaItems'], response_body['nextPageToken']]
    else
      Rails.logger.error "メディアアイテムの取得に失敗: #{response.body}"
      [nil, nil]
    end
  end

  def delete_session(session_id)
    response = @connection.delete("sessions/#{session_id}")
    if response.success?
      Rails.logger.info "セッション #{session_id} を正常に削除しました。"
    else
      Rails.logger.error "セッション削除に失敗: #{response.body}"
    end
    response
  end
end

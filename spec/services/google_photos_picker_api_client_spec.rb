# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GooglePhotosPickerApiClient do
  let(:access_token) { 'mock_access_token' }
  let(:session_id) { 'mock_session_id' }
  let(:client) { described_class.new(access_token) }
  let(:base_url) { GooglePhotosPickerApiClient::BASE_URL }

  describe '#create_session' do
    it 'returns session data if the request is successful' do
      response_body = { id: 'session_id' }.to_json
      mock_response = instance_double(Faraday::Response, success?: true, body: response_body)
      allow(client.instance_variable_get(:@connection)).to receive(:post)
        .with('sessions').and_return(mock_response)

      result = client.create_session
      expect(result['id']).to eq('session_id')
    end

    it 'logs an error and returns nil if the request fails' do
      mock_response = instance_double(Faraday::Response, success?: false, body: 'error')
      allow(client.instance_variable_get(:@connection)).to receive(:post)
        .with('sessions').and_return(mock_response)

      allow(Rails.logger).to receive(:error)

      result = client.create_session
      expect(Rails.logger).to have_received(:error).with('PickingSessionの作成に失敗: error')
      expect(result).to be_nil
    end
  end

  describe '#fetch_media_items' do
    it 'returns media items and next page token if the request is successful' do
      response_body = { mediaItems: %w[item1 item2], nextPageToken: 'token' }.to_json
      allow(client.instance_variable_get(:@connection)).to receive(:get)
        .with('mediaItems', { sessionId: session_id })
        .and_return(instance_double(Faraday::Response,
                                    success?: true, body: response_body))

      media_items, next_page_token = client.fetch_media_items(session_id)
      expect(media_items).to eq(%w[item1 item2])
      expect(next_page_token).to eq('token')
    end

    it 'logs an error and returns nil values if the request fails' do
      allow(client.instance_variable_get(:@connection)).to receive(:get)
        .with('mediaItems', { sessionId: session_id })
        .and_return(instance_double(Faraday::Response,
                                    success?: false, body: 'error'))

      allow(Rails.logger).to receive(:error)

      media_items, next_page_token = client.fetch_media_items(session_id)
      expect(Rails.logger).to have_received(:error).with('メディアアイテムの取得に失敗: error')
      expect(media_items).to be_nil
      expect(next_page_token).to be_nil
    end
  end

  describe '#delete_session' do
    it 'logs success if the session is deleted successfully' do
      allow(client.instance_variable_get(:@connection)).to receive(:delete)
        .with("sessions/#{session_id}")
        .and_return(instance_double(Faraday::Response,
                                    success?: true, body: ''))

      allow(Rails.logger).to receive(:info)

      client.delete_session(session_id)
      expect(Rails.logger).to have_received(:info).with("セッション #{session_id} を正常に削除しました。")
    end

    it 'logs an error if the session deletion fails' do
      allow(client.instance_variable_get(:@connection)).to receive(:delete)
        .with("sessions/#{session_id}")
        .and_return(instance_double(Faraday::Response,
                                    success?: false, body: 'error'))

      allow(Rails.logger).to receive(:error)

      client.delete_session(session_id)
      expect(Rails.logger).to have_received(:error).with('セッション削除に失敗: error')
    end
  end
end

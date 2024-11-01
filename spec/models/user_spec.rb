# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:user) { create(:user) }
  let(:auth) do
    OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: 'test_user_1',
      info: {
        name: 'Authenticated User',
        image: 'https://example.com/authenticated_user.jpg'
      }
    )
  end

  it 'validates uniqueness of uid scoped to provider' do
    create(:user, uid: '12345678', provider: 'google_oauth2')
    duplicate_user = build(:user, uid: '12345678', provider: 'google_oauth2')
    expect(duplicate_user).not_to be_valid
  end

  describe '.from_omniauth' do
    context 'when the user exists' do
      it 'updates the existing user' do
        existing_user = described_class.from_omniauth(auth)
        expect(existing_user.name).to eq('Authenticated User')
        expect(existing_user.provider).to eq('google_oauth2')
        expect(existing_user.uid).to eq('test_user_1')
        expect(existing_user.avatar_url).to eq('https://example.com/authenticated_user.jpg')
      end
    end

    context 'when the user does not exist' do
      it 'creates a new user' do
        new_user = described_class.from_omniauth(auth)
        expect(new_user.name).to eq('Authenticated User')
        expect(new_user.provider).to eq('google_oauth2')
        expect(new_user.uid).to eq('test_user_1')
        expect(new_user.avatar_url).to eq('https://example.com/authenticated_user.jpg')
        expect(new_user).to be_persisted
      end
    end
  end

  describe '#token_expired?' do
    it 'returns true if the token has expired' do
      expired_time = Time.zone.at(1.hour.ago.to_i)
      expect(user.token_expired?(expired_time)).to be true
    end

    it 'returns false if the token is still valid' do
      valid_time = Time.zone.at(1.hour.from_now.to_i)
      expect(user.token_expired?(valid_time)).to be false
    end
  end

  describe '#request_token_refresh' do
    let(:success_response) do
      instance_double(Faraday::Response, body: { 'access_token' => 'new_token', 'expires_in' => 3600 }.to_json,
                                         success?: true)
    end
    let(:failure_response) { instance_double(Faraday::Response, body: 'Error', success?: false) }

    it 'returns a new token if refresh is successful' do
      allow(user).to receive(:post_token_request).and_return(success_response)
      result = user.request_token_refresh('valid_refresh_token')
      expect(result['access_token']).to eq('new_token')
    end

    it 'returns nil if the refresh fails' do
      allow(user).to receive(:post_token_request).and_return(failure_response)
      result = user.request_token_refresh('invalid_refresh_token')
      expect(result).to be_nil
    end
  end
end

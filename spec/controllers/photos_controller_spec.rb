# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhotosController do
  let(:user) { create(:user) }
  let(:http_response) { instance_double(Net::HTTPSuccess, body: '{"mediaItems":[{"baseUrl":"mock_url"}]}') }

  before do
    sign_in user
    session[:access_token] = 'mock_access_token'
    session[:refresh_token] = 'mock_refresh_token'
    session[:token_expires_at] = 3600.seconds.from_now

    allow(controller).to receive(:current_user).and_return(user)
    allow(user).to receive_messages(token_expired?: true, request_token_refresh: { 'access_token' => 'new_access_token',
                                                                                   'expires_in' => 3600 })
    allow(Net::HTTP).to receive(:post_form).and_return(http_response)
  end

  describe 'GET #index' do
    it 'refreshes the token if it has expired' do
      session[:token_expires_at] = 1.hour.ago
      get :index
      expect(session[:access_token]).to eq('new_access_token')
    end

    it 'retrieves photos when the API call is successful' do
      allow(controller).to receive(:make_request).and_return(http_response)
      get :index
      expect(controller.instance_variable_get(:@photos)).to be_an(Array)
    end
  end
end

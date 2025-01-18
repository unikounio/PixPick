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

  describe '#participant_for' do
    let(:contest) { create(:contest) }

    context 'when the participant exists' do
      it 'returns the participant associated with the contest and user' do
        existing_participant = create(:participant, user:, contest:)
        participant = user.participant_for(contest)

        expect(participant).to eq(existing_participant)
      end
    end

    context 'when the participant does not exist' do
      it 'returns nil for a contest with no associated participant' do
        participant = user.participant_for(contest)
        expect(participant).to be_nil
      end
    end
  end
end

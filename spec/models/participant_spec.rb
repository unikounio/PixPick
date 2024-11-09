# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participant do
  let(:contest) { create(:contest) }
  let(:user) { create(:user) }

  describe 'validations' do
    subject(:participant) { build(:participant, contest: contest, user: user) }

    it { is_expected.to be_valid }

    context 'when user_id is missing' do
      it 'is invalid' do
        participant.user_id = nil
        expect(participant).not_to be_valid
      end
    end

    context 'when user participates in the same contest' do
      before { create(:participant, contest: contest, user: user) }

      it 'is invalid and has correct error message' do
        participant.valid?
        expect(participant).not_to be_valid
        expect(participant.errors[:user_id]).to include(I18n.t('activerecord.errors.messages.participated'))
      end
    end

    context 'when user participates in a different contest' do
      it 'is valid' do
        another_contest = create(:contest)
        described_class.create!(contest: another_contest, user: user)
        expect(participant).to be_valid
      end
    end
  end
end

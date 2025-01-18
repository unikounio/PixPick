# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vote do
  describe '.current_score' do
    let(:entry) { create(:entry) }
    let(:user) { create(:user) }

    context 'when a vote exists for the given entry and user' do
      it 'returns the score of the vote' do
        vote = create(:vote, user:, entry:)
        score = described_class.current_score(entry.id, user.id)

        expect(score).to eq(vote.score)
      end
    end

    context 'when no vote exists for the given entry and user' do
      it 'returns nil' do
        score = described_class.current_score(entry.id, user.id)

        expect(score).to be_nil
      end
    end
  end
end

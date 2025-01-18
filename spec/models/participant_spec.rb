# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participant do
  let(:contest) { create(:contest) }
  let(:user) { create(:user) }

  describe 'callbacks' do
    context 'when a participant is destroyed' do
      it 'destroys the contest if no participants remain' do
        participant = create(:participant, user:, contest:)

        expect(Contest.exists?(contest.id)).to be true

        participant.destroy

        expect(Contest.exists?(contest.id)).to be false
      end

      it 'does not destroy the contest if participants remain' do
        participants = create_list(:participant, 2, contest: contest)
        participants.first.destroy

        expect(Contest.exists?(contest.id)).to be true
      end
    end
  end
end

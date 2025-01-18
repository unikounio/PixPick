# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contest do
  let(:contest) { create(:contest) }
  let(:user) { create(:user) }

  describe 'Custom Validations' do
    it 'is invalid with a past deadline' do
      contest.deadline = Time.zone.today - 1.day
      expect(contest).not_to be_valid
      expect(contest.errors[:deadline])
        .to include(I18n.t('activerecord.errors.messages.past',
                           attribute: I18n.t('activerecord.attributes.contest.deadline')))
    end
  end

  describe '#add_participant' do
    it 'creates a new participant for the contest' do
      expect { contest.add_participant(user.id) }.to change(Participant, :count).by(1)
      participant = Participant.last
      expect(participant.user_id).to eq(user.id)
      expect(participant.contest_id).to eq(contest.id)
    end

    it 'does not create a participant if user_id is invalid' do
      expect { contest.add_participant(nil) }.not_to change(Participant, :count)
    end
  end

  describe '#entries_with_score_for' do
    let(:entry1) { create(:entry, contest:) }
    let(:vote) { create(:vote, user:, entry: entry1, score: 3) }

    it 'returns entries with the user’s scores' do
      vote
      entry2 = create(:entry, contest:)
      result = contest.entries_with_score_for(user)
      expect(result).to contain_exactly([entry2, nil], [entry1, 3])
    end

    it 'returns nil scores for entries without votes by the user' do
      vote
      other_user = create(:user)
      result = contest.entries_with_score_for(other_user)
      expect(result).to all(satisfy { |_, score| score.nil? })
    end
  end

  describe '#save_with_participant' do
    it 'saves the contest and creates a participant' do
      contest = build(:contest)
      expect { contest.save_with_participant(user.id) }
        .to change(described_class, :count).by(1)
                                           .and change(Participant, :count).by(1)
    end

    it 'rolls back both save and participant creation if participant creation fails' do
      contest = build(:contest, name: nil)

      expect(contest.save_with_participant(user.id)).to be_falsey
      expect(described_class.count).to eq(0)
      expect(Participant.count).to eq(0)
    end
  end

  describe '#deadline_passed?' do
    it 'returns true if the deadline has passed' do
      contest.update(deadline: Time.zone.yesterday)
      expect(contest.deadline_passed?).to be true
    end

    it 'returns false if the deadline is today or in the future' do
      contest.update(deadline: Time.zone.today)
      expect(contest.deadline_passed?).to be false

      contest.update(deadline: Time.zone.tomorrow)
      expect(contest.deadline_passed?).to be false
    end
  end

  describe '#determine_updated_message' do
    it 'returns both name and deadline if both have changed' do
      contest.update(name: 'New Name', deadline: Time.zone.tomorrow)
      expect(contest.determine_updated_message).to eq('コンテスト名と投票期日')
    end

    it 'returns name if only the name has changed' do
      contest.update(name: 'New Name')
      expect(contest.determine_updated_message).to eq('コンテスト名')
    end

    it 'returns deadline if only the deadline has changed' do
      contest.update(deadline: Time.zone.tomorrow)
      expect(contest.determine_updated_message).to eq('投票期日')
    end

    it 'returns nil if neither has changed' do
      contest.reload
      expect(contest.determine_updated_message).to be_nil
    end
  end
end

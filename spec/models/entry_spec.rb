# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entry do
  let(:contest) { create(:contest) }
  let(:user) { create(:user) }

  describe 'validations' do
    subject(:entry) { build(:entry, contest: contest, user: user) }

    it { is_expected.to be_valid }

    it 'is invalid without a drive_file_id' do
      entry.drive_file_id = nil
      expect(entry).not_to be_valid
      expect(entry.errors[:drive_file_id]).to include(I18n.t('errors.messages.blank'))
    end

    context 'when a drive_file_id is already taken within the same contest' do
      before { create(:entry, drive_file_id: entry.drive_file_id, contest: contest, user: user) }

      it 'is invalid with a duplicate drive_file_id within the same contest' do
        expect(entry).not_to be_valid
        expect(entry.errors[:drive_file_id]).to include(I18n.t('activerecord.errors.messages.entered'))
      end
    end

    it 'is valid with the same drive_file_id in a different contest' do
      another_contest = create(:contest)
      described_class.create!(drive_file_id: entry.drive_file_id, contest: another_contest, user: user)
      expect(entry).to be_valid
    end
  end
end

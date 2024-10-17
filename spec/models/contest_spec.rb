# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contest do
  describe 'Validations' do
    let(:contest) { described_class.new(name: 'Photo Contest', deadline:) }
    let(:deadline) { Time.zone.today + 1.day }

    it 'is valid with valid attributes' do
      expect(contest).to be_valid
    end

    it 'is invalid without a name' do
      contest.name = nil
      expect(contest).not_to be_valid
      expect(contest.errors[:name]).to include(I18n.t('errors.messages.blank'))
    end

    it 'is invalid without a deadline' do
      contest.deadline = nil
      expect(contest).not_to be_valid
      expect(contest.errors[:deadline]).to include(I18n.t('errors.messages.blank'))
    end

    it 'is invalid with a past deadline' do
      contest.deadline = Time.zone.today - 1.day
      expect(contest).not_to be_valid
      expect(contest.errors[:deadline])
        .to include(I18n.t('activerecord.errors.messages.past',
                           attribute: I18n.t('activerecord.attributes.contest.deadline')))
    end
  end
end

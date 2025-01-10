# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contests' do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'Contest index' do
    it 'displays a list of contests' do
      contests =
        create_list(:contest, 2).each do |contest|
          create(:participant, contest:, user:)
        end

      visit user_contests_path(user)

      contests.each do |contest|
        expect(page).to have_content(contest.name)
      end
    end
  end

  describe 'Contest show' do
    it 'displays contest details' do
      contest = create(:contest)
      create(:participant, contest:, user:)

      visit contest_path(contest)

      expect(page).to have_content(contest.name)
      expect(page).to have_content(I18n.t('activerecord.attributes.contest.deadline'))
    end
  end

  describe 'Contest creation' do
    it 'creates a new contest successfully' do
      visit new_contest_path

      fill_in 'contest_name', with: 'New Contest'
      fill_in 'contest_deadline', with: (Time.zone.today + 1.week)

      click_on I18n.t('helpers.submit.contest.create')

      expect(page).to have_content I18n.t('activerecord.notices.messages.create',
                                          model: I18n.t('activerecord.models.contest'))
      expect(page).to have_current_path(new_contest_entry_path(Contest.last))
    end

    it 'fails to create a contest with invalid data' do
      visit new_contest_path

      fill_in 'contest_name', with: ''
      fill_in 'contest_deadline', with: (Time.zone.today - 1.week)

      click_on I18n.t('helpers.submit.contest.create')

      expect(page).to have_content I18n.t('errors.messages.blank')
      expect(page).to have_content I18n.t('activerecord.errors.messages.past',
                                          attribute: I18n.t('activerecord.attributes.contest.deadline'))
    end
  end

  describe 'Contest edit' do
    it 'displays the edit form with initial values' do
      contest = create(:contest)
      create(:participant, contest:, user:)

      visit edit_contest_path(contest)

      expect(find_field('contest_name').value).to eq(contest.name)
      expect(Time.zone.parse(find_field('contest_deadline').value)).to eq(contest.deadline)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contests' do
  let(:user) { create(:user) }
  let(:contest) { create(:contest) }

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

  describe 'Contest details and ranking' do
    it 'displays contest details' do
      visit contest_path(contest)

      expect(page).to have_content(contest.name)
      expect(page).to have_content(I18n.t('activerecord.attributes.contest.deadline'))
    end

    it 'displays the ranking correctly' do
      [3, 1, 1].each do |score|
        entry = create(:entry, contest:)
        create(:vote, entry:, score:)
      end

      visit ranking_contest_path(contest)

      within('table') do
        rows = page.all('tr')

        expected_rows = [%w[1 3pt], %w[2 1pt], %w[2 1pt]]

        expected_rows.each_with_index do |(rank, score), index|
          within(rows[index]) do
            first_cell = find('td:first-child')
            expect(first_cell).to have_content(rank)
            expect(first_cell).to have_content(score)
          end
        end
      end
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

  describe 'Contest editing' do
    it 'displays the edit form with initial values' do
      visit edit_contest_path(contest)

      expect(find_field('contest_name').value).to eq(contest.name)
      expect(Time.zone.parse(find_field('contest_deadline').value)).to eq(contest.deadline)
    end

    it 'updates a contest successfully' do
      visit edit_contest_path(contest)

      fill_in 'contest_name', with: 'Updated Contest Name'
      click_on '更新する'

      expect(page).to have_content('コンテスト名を更新しました')
      expect(find_field('contest_name').value).to have_content('Updated Contest Name')
    end

    it 'fails to update with invalid data' do
      visit edit_contest_path(contest)

      fill_in 'contest_name', with: ''
      click_on '更新する'

      expect(page).to have_content(I18n.t('errors.messages.blank'))
    end
  end

  describe 'Contest destroy' do
    it 'deletes a contest successfully' do
      visit edit_contest_path(contest)

      initial_count = Contest.count

      accept_confirm do
        click_on 'コンテストを削除する'
      end

      expect(page).to have_current_path(user_contests_path(user))
      expect(Contest.count).to eq(initial_count - 1)
      expect(page).to have_content('コンテストが削除されました。')
    end
  end
end

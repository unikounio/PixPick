# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contests' do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'Contest creation' do
    let(:client) { instance_double(GooglePhotosPickerApiClient) }
    let(:mock_picking_session) do
      {
        'id' => 'mock_session_id',
        'mediaItemsSet' => false,
        'pickerUri' => 'https://mockpickeruri.com'
      }
    end

    it 'creates a new contest successfully' do
      allow(GooglePhotosPickerApiClient).to receive(:new).and_return(client)
      allow(client).to receive(:create_session).and_return(mock_picking_session)
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
end

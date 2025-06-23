# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Entries' do
  let(:user) { create(:user) }
  let(:contest) { create(:contest) }
  let(:entry) { create(:entry, contest: contest, user: user) }

  before do
    sign_in user
    create(:participant, contest:, user:)
  end

  describe 'GET /contests/:contest_id/entries/:id' do
    it 'responds with 200 OK when rendering the show page' do
      get contest_entry_path(contest, entry)
      expect(response).to have_http_status(:ok)
    end

    it 'includes IDs of previous and next entries in the response body' do
      previous_entry = create(:entry, contest: contest, id: entry.id - 1)
      next_entry = create(:entry, contest: contest, id: entry.id + 1)

      get contest_entry_path(contest, entry)
      expect(response.body).to include(previous_entry.id.to_s)
      expect(response.body).to include(next_entry.id.to_s)
    end
  end

  describe 'GET /contests/:contest_id/entries/new' do
    it 'responds with 200 OK when rendering the new page' do
      get new_contest_entry_path(contest)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /contests/:contest_id/entries' do
    file = Rack::Test::UploadedFile.new(Rails.root.join('spec/files/sample.jpg'), 'image/jpeg')

    context 'with valid parameters' do
      it 'creates a new entry and returns JSON' do
        post contest_entries_path(contest), params: { files: [file] }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('redirect_url')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        post contest_entries_path(contest), params: { files: [] }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('ファイルが見つかりません')
      end
    end
  end

  describe 'DELETE /entries/:id' do
    it 'deletes the entry and returns Turbo Stream response' do
      entry
      expect do
        delete contest_entry_path(contest, entry)
      end.to change(Entry, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("entry_#{entry.id}")
    end
  end

  it 'does not delete entry if unauthorized' do
    other_user = create(:user)
    other_entry = create(:entry, contest: contest, user: other_user)

    expect do
      delete contest_entry_path(contest, other_entry)
    end.not_to change(Entry, :count)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t('activerecord.errors.messages.unauthorized',
                                            model: I18n.t('activerecord.models.entry')))
  end
end

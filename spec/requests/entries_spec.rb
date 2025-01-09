require 'rails_helper'

RSpec.describe "Entries", type: :request do
  let(:user) { create(:user) }
  let(:contest) { create(:contest) }
  let(:entry) { create(:entry, contest: contest, user: user) }

  before { sign_in user }

  describe "GET /contests/:contest_id/entries/:id" do
    it "responds with 200 OK when rendering the show page" do
      get contest_entry_path(contest, entry)
      expect(response).to have_http_status(200)
    end

    it "includes IDs of previous and next entries in the response body" do
      previous_entry = create(:entry, contest: contest, id: entry.id - 1)
      next_entry = create(:entry, contest: contest, id: entry.id + 1)

      get contest_entry_path(contest, entry)
      expect(response.body).to include(previous_entry.id.to_s)
      expect(response.body).to include(next_entry.id.to_s)
    end
  end
end

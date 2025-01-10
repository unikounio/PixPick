require 'rails_helper'

RSpec.describe "Contests", type: :request do
  let(:user) { create(:user) }
  let(:contest) { create(:contest) }

  before do
    sign_in user
  end

  describe 'GET /contests/:id/invite' do
    it 'generates the correct invite URL' do
      get invite_contest_path(contest)

      expect(response).to have_http_status(200)
      expect(response.body).to include(
        new_contest_participant_path(
          contest_id: contest.id,
          token: contest.invitation_token
        )
      )
    end
  end
end

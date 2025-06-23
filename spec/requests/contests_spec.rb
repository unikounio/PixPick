# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contests' do
  let(:user) { create(:user) }
  let(:contest) { create(:contest) }

  before do
    sign_in user
    create(:participant, contest:, user:)
  end

  describe 'PATCH /contests/:id' do
    context 'when the update is successful' do
      let(:new_deadline) { Time.zone.tomorrow.beginning_of_day }

      it 'updates both the contest name and deadline' do
        patch contest_path(contest), params: { contest: { name: 'Updated Contest', deadline: new_deadline } },
                                     headers: { 'HTTP_ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(response.body).to include('コンテスト名と投票期日を更新しました')
        expect(contest.reload.name).to eq('Updated Contest')
        expect(contest.reload.deadline).to eq(new_deadline)
      end

      it 'updates only the contest name' do
        current_deadline = contest.deadline
        patch contest_path(contest), params: { contest: { name: 'Updated Contest', deadline: current_deadline } },
                                     headers: { 'HTTP_ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(response.body).to include('コンテスト名を更新しました')
        expect(contest.reload.name).to eq('Updated Contest')
        expect(contest.reload.deadline).to eq(current_deadline)
      end

      it 'updates only the contest deadline' do
        current_name = contest.name
        patch contest_path(contest), params: { contest: { name: current_name, deadline: new_deadline } },
                                     headers: { 'HTTP_ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(response.body).to include('投票期日を更新しました')
        expect(contest.reload.name).to eq(current_name)
        expect(contest.reload.deadline).to eq(new_deadline)
      end
    end

    context 'when no changes are made' do
      it 'returns an error message' do
        patch contest_path(contest), params: { contest: { name: contest.name, deadline: contest.deadline } },
                                     headers: { 'HTTP_ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(response.body).to include('更新する項目がありません')
      end
    end

    context 'when the update fails' do
      it 'returns an error message' do
        patch contest_path(contest), params: { contest: { name: '', deadline: contest.deadline } },
                                     headers: { 'HTTP_ACCEPT' => 'text/vnd.turbo-stream.html' }
        expect(response.body).to include('コンテスト名を入力してください')
      end
    end
  end

  describe 'GET /contests/:id/invite' do
    it 'generates the correct invite URL' do
      get invite_contest_path(contest)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        new_contest_participant_path(
          contest_id: contest.id,
          token: contest.invitation_token
        )
      )
    end
  end

  describe 'DELETE /contests/:id' do
    it 'deletes the contest and redirects with a success message' do
      contest
      expect do
        delete contest_path(contest)
      end.to change(Contest, :count).by(-1)
      expect(response).to redirect_to(user_contests_path(user))
      follow_redirect!
      expect(response.body).to include('コンテストが削除されました。')
    end
  end
end

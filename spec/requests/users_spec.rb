# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users' do
  describe 'DELETE /users/:id' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'deletes the user, resets the session, and redirects to the root path with a notice' do
      expect do
        delete user_path(user)
      end.to change(User, :count).by(-1)

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('退会しました')
    end
  end
end

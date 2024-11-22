# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#user_avatar_url' do
    context 'when current_user has an avatar_url' do
      it 'returns the user avatar_url' do
        user = build_stubbed(:user, avatar_url: 'http://example.com/avatar.png')
        allow(helper).to receive(:current_user).and_return(user)

        expect(helper.user_avatar_url).to eq('http://example.com/avatar.png')
      end
    end

    context 'when current_user does not have an avatar_url' do
      it 'returns the default avatar path' do
        user = build_stubbed(:user, avatar_url: nil)
        allow(helper).to receive(:asset_path).with('default_avatar.png').and_return('/assets/default_avatar.png')
        allow(helper).to receive(:current_user).and_return(user)

        expect(helper.user_avatar_url).to eq('/assets/default_avatar.png')
      end
    end

    context 'when there is no current_user' do
      it 'returns the default avatar path' do
        allow(helper).to receive(:asset_path).with('default_avatar.png').and_return('/assets/default_avatar.png')
        allow(helper).to receive(:current_user).and_return(nil)

        expect(helper.user_avatar_url).to eq('/assets/default_avatar.png')
      end
    end
  end
end

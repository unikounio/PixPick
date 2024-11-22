# frozen_string_literal: true

module ApplicationHelper
  def user_avatar_url
    current_user&.avatar_url || asset_path('default_avatar.png')
  end
end

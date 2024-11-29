# frozen_string_literal: true

module ApplicationHelper
  def user_avatar_url
    current_user&.avatar_url || asset_path('default_avatar.png')
  end

  def toast_border_css(type)
    if type == :success
      'border-gray-200 dark:bg-neutral-800 dark:border-neutral-700'
    else
      'border-red-300 dark:bg-red-800 dark:border-red-700'
    end
  end

  def toast_text_css(type)
    if type == :success
      'text-gray-700 dark:text-neutral-400'
    else
      'text-gray-700 dark:text-gray-100'
    end
  end
end

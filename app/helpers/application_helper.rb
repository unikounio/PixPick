# frozen_string_literal: true

module ApplicationHelper
  def user_avatar_url
    current_user&.avatar_url || asset_path('default_avatar.png')
  end

  def tailwind_classes_for(flash_type)
    {
      notice: 'bg-white border-l-4 border-green-500 text-black',
      participation_notice: 'bg-white border-l-4 border-green-500 text-black',
      alert: 'bg-white border-l-4 border-red-500 text-black',
      participation_alert: 'bg-white border-l-4 border-red-500 text-black'
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def notice_type?(flash_type)
    %w[notice participation_notice].include?(flash_type.to_s)
  end

  def alert_type?(flash_type)
    %w[alert participation_alert].include?(flash_type.to_s)
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

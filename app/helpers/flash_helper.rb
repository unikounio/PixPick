# frozen_string_literal: true

module FlashHelper
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
end

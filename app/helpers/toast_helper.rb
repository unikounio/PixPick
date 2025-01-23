# frozen_string_literal: true

module ToastHelper
  def toast_border_css(type)
    if type == :success
      'border-stone-200 dark:bg-stone-800 dark:border-stone-700'
    else
      'border-red-300 dark:bg-red-800 dark:border-red-700'
    end
  end

  def toast_text_css(type)
    if type == :success
      'text-stone-700 dark:text-stone-400'
    else
      'text-stone-700 dark:text-stone-100'
    end
  end
end

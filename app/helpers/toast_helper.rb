# frozen_string_literal: true

module ToastHelper
  def toast_border_css(type)
    if type == :success
      'border-stone-200'
    else
      'border-red-300'
    end
  end
end

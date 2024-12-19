# frozen_string_literal: true

module ContestsHelper
  def tab_link_classes(current_path, target_path, extra_classes = '')
    if current_path == target_path
      "bg-white text-black #{extra_classes}"
    else
      "bg-stone-100 text-stone-500 #{extra_classes}"
    end
  end
end

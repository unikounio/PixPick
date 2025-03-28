# frozen_string_literal: true

module ContestsHelper
  def current_contest_or_contests_index_path(contest, current_user)
    if contest&.persisted?
      contest_path(contest)
    else
      user_contests_path(current_user)
    end
  end

  def tab_link_classes(current_path, target_path)
    if current_path == target_path
      'bg-white btn-tab'
    else
      'bg-stone-100 text-stone-500 hover:bg-white hover:text-stone-700 transition btn-tab'
    end
  end
end

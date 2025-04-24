# frozen_string_literal: true

module EntriesHelper
  def score_button_variant(entry, user, score)
    current_score = Vote.current_score(entry.id, user.id)

    if score == current_score
      'text-white bg-cyan-500 border border-cyan-500'
    else
      'bg-white hover:bg-stone-300 transition border border-stone-300'
    end
  end
end

# frozen_string_literal: true

class Ranking
  attr_reader :ranked_entries

  def initialize(entries_with_scores)
    @entries = entries_with_scores
    @ranked_entries = []
  end

  def calculate
    current_rank = 0
    previous_score = nil

    @entries.each_with_index do |entry, index|
      if entry.total_score != previous_score
        current_rank = index + 1
        previous_score = entry.total_score
      end

      @ranked_entries << {
        rank: current_rank,
        entry:,
        total_score: entry.total_score
      }
    end

    self
  end
end

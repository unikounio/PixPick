# frozen_string_literal: true

class Ranking
  attr_reader :rank, :entry, :total_score

  def initialize(rank:, entry:, total_score:)
    @rank = rank
    @entry = entry
    @total_score = total_score
  end

  def self.calculate(entries_with_scores)
    ranked_entries = []
    current_rank = 0
    previous_score = nil

    entries_with_scores.each_with_index do |entry, index|
      if entry.total_score != previous_score
        current_rank = index + 1
        previous_score = entry.total_score
      end

      ranked_entries << new(
        rank: current_rank,
        entry:,
        total_score: entry.total_score
      )
    end

    ranked_entries
  end
end

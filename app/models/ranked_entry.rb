# frozen_string_literal: true

class RankedEntry
  attr_reader :rank, :entry, :total_score

  def initialize(rank:, entry:, total_score:)
    @rank = rank
    @entry = entry
    @total_score = total_score
  end
end

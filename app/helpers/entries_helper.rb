# frozen_string_literal: true

module EntriesHelper
  def display_entries?(entry_scores, uploading_counts)
    entry_scores.any? || uploading_counts.present?
  end
end

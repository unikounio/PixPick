# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  validates :entry_id, uniqueness: { scope: :user_id }
  validate :contest_must_be_open_for_voting

  def self.current_score(entry_id, user_id)
    find_by(entry_id:, user_id:)&.score
  end

  private

  def contest_must_be_open_for_voting
    return unless entry.contest.deadline.end_of_day.past?

    errors.add(:base, 'このコンテストは投票期日を過ぎているため投票できません')
  end
end

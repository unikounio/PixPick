# frozen_string_literal: true

class Participant < ApplicationRecord
  belongs_to :contest
  belongs_to :user

  validates :user_id, uniqueness: { scope: :contest_id, message: :participated }

  after_destroy :destroy_contest_if_no_participants

  private

  def destroy_contest_if_no_participants
    contest.destroy if contest.participants.count.zero?
  end
end

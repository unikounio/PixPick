# frozen_string_literal: true

class Contest < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :entries, dependent: :destroy

  validates :name, presence: true
  validates :deadline, presence: true
  validates :invitation_token, uniqueness: true, length: { maximum: 64 }
  validate :deadline_cannot_be_in_the_past

  scope :recently_updated, ->(limit_count) { order(updated_at: :desc).limit(limit_count) }

  before_create :generate_invitation_token

  def add_participant(user_id)
    participant = Participant.new(user_id: user_id, contest_id: id)
    participant.save
  end

  def entries_with_score_for(user)
    entries.includes(:image_attachment).order(created_at: :desc).map do |entry|
      score = user.votes.find_by(entry_id: entry.id)&.score
      [entry, score]
    end
  end

  def sort_entries_by_total_score
    entries.includes(:image_attachment).with_total_scores.order(total_score: :desc, id: :asc)
  end

  def save_with_participant(user_id)
    transaction do
      save!
      participants.create!(user_id:)
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "参加者の作成に失敗: #{e.message}"
    false
  end

  def deadline_passed?
    deadline.end_of_day.past?
  end

  def determine_updated_message
    if saved_change_to_name? && saved_change_to_deadline?
      'コンテスト名と投票期日'
    elsif saved_change_to_name?
      'コンテスト名'
    elsif saved_change_to_deadline?
      '投票期日'
    end
  end

  private

  def deadline_cannot_be_in_the_past
    return unless deadline.present? && deadline.to_date < Time.zone.today

    errors.add(:deadline, :past)
  end

  def generate_invitation_token
    self.invitation_token ||= SecureRandom.urlsafe_base64
  end
end

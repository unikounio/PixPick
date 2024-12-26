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

  def entry_scores_for(user)
    entries.order(created_at: :desc).map do |entry|
      score = user.votes.find_by(entry_id: entry.id)&.score
      [entry.id, score]
    end
  end

  def uploading_entry_counts(session)
    redis = Redis.new
    status_key = "uploading_#{id}"
    status = redis.get(status_key)

    if status == 'completed'
      Thread.new do
        sleep(2)
        redis.del(status_key)
      end
      session.delete(:"contest_#{id}_uploading_entry_counts")
      nil
    else
      session[:"contest_#{id}_uploading_entry_counts"]
    end
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

  private

  def deadline_cannot_be_in_the_past
    return unless deadline.present? && deadline.to_date < Time.zone.today

    errors.add(:deadline, :past)
  end

  def generate_invitation_token
    self.invitation_token ||= SecureRandom.urlsafe_base64
  end
end

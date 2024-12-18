# frozen_string_literal: true

class Contest < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :entries, dependent: :destroy

  validates :name, presence: true
  validates :deadline, presence: true
  validates :drive_permission_id, uniqueness: { scope: :drive_file_id }
  validates :invitation_token, uniqueness: true, length: { maximum: 64 }
  validate :deadline_cannot_be_in_the_past

  scope :recently_updated, ->(limit_count) { order(updated_at: :desc).limit(limit_count) }

  before_create :generate_invitation_token

  def add_participant(user_id)
    participant = Participant.new(user_id: user_id, contest_id: id)
    participant.save
  end

  def save_contest_and_create_participant(folder_id, permission_id, user_id)
    ActiveRecord::Base.transaction do
      self.drive_file_id = folder_id
      self.drive_permission_id = permission_id
      save!
      participants.create!(user_id:)
    end
  rescue ActiveRecord::RecordInvalid
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

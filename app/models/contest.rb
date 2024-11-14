# frozen_string_literal: true

class Contest < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :entries, dependent: :destroy

  validates :name, presence: true
  validates :deadline, presence: true
  validates :drive_permission_id, uniqueness: { scope: :drive_file_id }
  validate :deadline_cannot_be_in_the_past

  private

  def deadline_cannot_be_in_the_past
    return unless deadline.present? && deadline.to_date < Time.zone.today

    errors.add(:deadline, :past)
  end
end

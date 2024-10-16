# frozen_string_literal: true

class Contest < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :entries, dependent: :destroy

  validates :name, presence: { message: 'コンテスト名を入力してください' }
  validates :deadline, presence: { message: '投票期日を設定してください' }
  validate :deadline_cannot_be_in_the_past

  private

  def deadline_cannot_be_in_the_past
    return unless deadline.present? && deadline.to_date < Time.zone.today

    errors.add(:deadline,
               I18n.t('activerecord.errors.models.contest.attributes.deadline.past'))
  end
end

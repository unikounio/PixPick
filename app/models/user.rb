# frozen_string_literal: true

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[google_oauth2]

  has_many :participants, dependent: :destroy
  has_many :contests, through: :participants
  has_many :entries, dependent: :destroy
  has_many :votes, dependent: :destroy

  validates :name, presence: true
  validates :uid, uniqueness: { scope: :provider, message: :registered }

  def self.from_omniauth(auth)
    user = find_or_create_by(provider: auth.provider, uid: auth.uid)
    user.name = auth.info.name.presence || I18n.t('users.guest')
    user.avatar_url = auth.info.image
    user.save!
    user
  end

  def participant_for(contest)
    participants.find { |p| p.contest_id == contest.id }
  end
end

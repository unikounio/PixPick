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

  def token_expired?(token_expires_at)
    return true if token_expires_at.nil?

    token_expires_at < Time.current
  end

  def request_token_refresh(refresh_token)
    response = post_token_request(refresh_token)

    if response.success?
      JSON.parse(response.body)
    else
      logger.error "アクセストークン更新失敗: #{response.body}"
      nil
    end
  end

  def participant_for(contest)
    participants.find { |p| p.contest_id == contest.id }
  end

  private

  def post_token_request(refresh_token)
    Faraday.post('https://oauth2.googleapis.com/token') do |req|
      req.body = {
        client_id: ENV.fetch('GOOGLE_CLIENT_ID', nil),
        client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET', nil),
        refresh_token:,
        grant_type: 'refresh_token'
      }
    end
  end
end

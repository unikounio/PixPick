# frozen_string_literal: true

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[google_oauth2]

  has_many :participants, dependent: :destroy
  has_many :contests, through: :participants
  has_many :entries, dependent: :destroy

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

    Time.zone.at(token_expires_at) < Time.current
  end

  def request_token_refresh(refresh_token)
    response = post_token_request(refresh_token)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      logger.error "アクセストークン更新失敗: #{response.body}"
      nil
    end
  end

  private

  def post_token_request(refresh_token)
    Net::HTTP.post_form(
      URI('https://oauth2.googleapis.com/token'),
      {
        client_id: ENV.fetch('GOOGLE_CLIENT_ID', nil),
        client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET', nil),
        refresh_token:,
        grant_type: 'refresh_token'
      }
    )
  end
end

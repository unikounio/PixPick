class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[google_oauth2]
  validates :uid, uniqueness: { scope: :provider }
  def self.from_omniauth(auth)
    user = find_or_create_by(provider: auth.provider, uid: auth.uid)
    user.name = auth.info.name
    user.avatar_url = auth.info.image
    user.save!
    user
  end
end

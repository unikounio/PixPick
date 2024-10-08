FactoryBot.define do
  factory :user do
    name { 'test_name' }
    sequence(:uid) { |n| "test_user_#{n}" }
    provider { 'google_oauth2' }
    avatar_url { "https://example.com/test_user.jpg" }
  end
end

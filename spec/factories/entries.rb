# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    media_item_id { '1' }
    base_url { 'https://example.com/photo.jpg' }
    base_url_updated_at { '2024-11-04 00:00:00.700888000 +0900' }
    contest
    user
  end
end

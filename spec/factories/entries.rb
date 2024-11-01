# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    photo_url { 'https://example.com/photo.jpg' }
    contest
    user
  end
end

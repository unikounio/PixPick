# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    base_url { 'https://example.com/photo.jpg' }
    contest
    user
  end
end

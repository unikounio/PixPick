# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    photo_url { 'MyString' }
    contest { nil }
    user { nil }
  end
end

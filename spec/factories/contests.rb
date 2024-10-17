# frozen_string_literal: true

FactoryBot.define do
  factory :contest do
    name { 'Test Contest' }
    deadline { Time.zone.now.beginning_of_day }
  end
end

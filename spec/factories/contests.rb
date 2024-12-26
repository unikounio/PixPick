# frozen_string_literal: true

FactoryBot.define do
  factory :contest do
    name { 'Test Contest' }
    deadline { Time.current.beginning_of_day }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :participant do
    contest
    user
  end
end

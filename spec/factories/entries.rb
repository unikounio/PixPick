# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    sequence(:drive_file_id, &:to_s)
    contest
    user
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :contest do
    name { 'Test Contest' }
    deadline { Time.current.beginning_of_day }
    sequence(:drive_file_id, &:to_s)
    sequence(:drive_permission_id, &:to_s)
  end
end

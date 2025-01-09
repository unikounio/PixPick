# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    contest
    user

    after(:build) do |entry|
      entry.image.attach(
        io: File.open(Rails.root.join('spec/files/sample.jpg')),
        filename: 'sample.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end

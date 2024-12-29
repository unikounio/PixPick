# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    contest
    user

    after(:build) do |entry|
      entry.image.attach(
        io: StringIO.new('This is a dummy image file'),
        filename: 'dummy.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end

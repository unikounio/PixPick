# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :contest
  belongs_to :user

  validates :photo_url, presence: true,
                        uniqueness: { scope: :contest_id, message: :entered }
end

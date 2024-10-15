# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :contest
  belongs_to :user

  validates :photo_url, uniqueness: { scope: :contest_id, message: 'この写真は既にエントリーしています' }
end

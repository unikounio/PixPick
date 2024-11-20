# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :contest
  belongs_to :user

  validates :drive_file_id, presence: true,
                            uniqueness: { scope: :contest_id, message: :entered }
  validates :drive_permission_id, uniqueness: { scope: :drive_file_id }
end

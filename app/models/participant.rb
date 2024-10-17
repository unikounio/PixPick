# frozen_string_literal: true

class Participant < ApplicationRecord
  belongs_to :contest
  belongs_to :user

  validates :user_id, uniqueness: { scope: :contest_id, message: :participated }
end

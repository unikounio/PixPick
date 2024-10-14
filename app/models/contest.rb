# frozen_string_literal: true

class Contest < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
end

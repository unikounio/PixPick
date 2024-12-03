# frozen_string_literal: true

class CreateVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :votes do |t|
      t.integer :score, null: false
      t.references :user, null: false, foreign_key: true
      t.references :entry, null: false, foreign_key: true

      t.timestamps
    end
    add_index :votes, %i[entry_id user_id], unique: true
    add_check_constraint :votes, 'score BETWEEN 1 AND 3', name: 'check_score_range'
  end
end

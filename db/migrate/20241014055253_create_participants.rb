# frozen_string_literal: true

class CreateParticipants < ActiveRecord::Migration[7.2]
  def change
    create_table :participants do |t|
      t.references :contest, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :participants, %i[user_id contest_id], unique: true
  end
end

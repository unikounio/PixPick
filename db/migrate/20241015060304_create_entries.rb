# frozen_string_literal: true

class CreateEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :entries do |t|
      t.string :base_url
      t.references :contest, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :entries, %i[base_url contest_id], unique: true
  end
end

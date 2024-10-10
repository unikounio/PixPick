# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :avatar_url
      t.timestamps null: false
    end
    add_index :users, %i[uid provider], unique: true
  end
end

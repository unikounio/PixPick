# frozen_string_literal: true

class AddNotNullConstraints < ActiveRecord::Migration[7.2]
  def change
    change_table :contests, bulk: true do |t|
      t.change_null :name, false
      t.change_null :deadline, false
    end

    change_table :entries, bulk: true do |t|
      t.change_null :base_url, false
    end

    change_table :users, bulk: true do |t|
      t.change_null :name, false
    end
  end
end

# frozen_string_literal: true

class AddMediaItemIdAndBaseUrlUpdatedAtToEntries < ActiveRecord::Migration[7.2]
  def change
    change_table :entries, bulk: true do |t|
      t.string :media_item_id
      t.datetime :base_url_updated_at
    end

    remove_index :entries, %i[base_url contest_id], name: 'index_entries_on_base_url_and_contest_id'
    add_index :entries, %i[media_item_id contest_id], unique: true
    add_index :entries, :base_url_updated_at
  end
end

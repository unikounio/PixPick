# frozen_string_literal: true

class UpdateEntriesTable < ActiveRecord::Migration[7.2]
  def change
    change_table :entries, bulk: true do |t|
      t.string :drive_file_id

      t.remove :base_url, type: :string
      t.remove :media_item_id, type: :string
      t.remove :base_url_updated_at, type: :datetime
    end

    add_index :entries, %i[drive_file_id contest_id], unique: true

    remove_index :entries, %i[media_item_id contest_id] if index_exists?(:entries, %i[media_item_id contest_id])
    remove_index :entries, :base_url_updated_at if index_exists?(:entries, :base_url_updated_at)
  end
end

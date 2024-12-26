# frozen_string_literal: true

class RemoveDriveColumnsFromContestsAndEntries < ActiveRecord::Migration[7.2]
  def change
    change_table :contests, bulk: true do |t|
      t.remove :drive_file_id, type: :string
      t.remove :drive_permission_id, type: :string
    end

    change_table :entries, bulk: true do |t|
      t.remove :drive_file_id, type: :string
      t.remove :drive_permission_id, type: :string
    end
  end
end

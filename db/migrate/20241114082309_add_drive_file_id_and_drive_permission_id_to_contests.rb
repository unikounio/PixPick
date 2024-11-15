# frozen_string_literal: true

class AddDriveFileIdAndDrivePermissionIdToContests < ActiveRecord::Migration[7.2]
  def change
    change_table :contests, bulk: true do |t|
      t.string :drive_file_id
      t.string :drive_permission_id
    end

    add_index :contests, %i[drive_file_id drive_permission_id], unique: true
  end
end

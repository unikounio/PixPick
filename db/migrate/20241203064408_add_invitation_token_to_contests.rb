# frozen_string_literal: true

class AddInvitationTokenToContests < ActiveRecord::Migration[7.2]
  def change
    add_column :contests, :invitation_token, :string
    add_index :contests, :invitation_token, unique: true
  end
end

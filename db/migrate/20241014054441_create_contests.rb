class CreateContests < ActiveRecord::Migration[7.2]
  def change
    create_table :contests do |t|
      t.string :name
      t.datetime :deadline

      t.timestamps
    end
  end
end

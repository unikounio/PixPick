# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_02_112320) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contests", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "deadline", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.string "base_url", null: false
    t.bigint "contest_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "media_item_id"
    t.datetime "base_url_updated_at"
    t.index ["base_url_updated_at"], name: "index_entries_on_base_url_updated_at"
    t.index ["contest_id"], name: "index_entries_on_contest_id"
    t.index ["media_item_id", "contest_id"], name: "index_entries_on_media_item_id_and_contest_id", unique: true
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "participants", force: :cascade do |t|
    t.bigint "contest_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_participants_on_contest_id"
    t.index ["user_id", "contest_id"], name: "index_participants_on_user_id_and_contest_id", unique: true
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "entries", "contests"
  add_foreign_key "entries", "users"
  add_foreign_key "participants", "contests"
  add_foreign_key "participants", "users"
end

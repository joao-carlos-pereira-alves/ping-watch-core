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

ActiveRecord::Schema[7.0].define(version: 2024_08_23_225553) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "exports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.integer "total_count", default: 0
    t.integer "total_processed", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "quantity"
    t.decimal "unit_price", precision: 10, scale: 2
    t.decimal "total", precision: 12, scale: 2
    t.uuid "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "site_checks", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.integer "check_status", null: false
    t.integer "response_time_ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "response_time_ms"], name: "index_site_checks_on_site_id_and_response_time_ms"
    t.index ["site_id"], name: "index_site_checks_on_site_id"
  end

  create_table "sites", force: :cascade do |t|
    t.bigint "user_id"
    t.string "url"
    t.integer "status", default: 0
    t.string "uuid", default: "56986f18-fba6-42be-a25c-c5b7f8f54bf2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hostname"
    t.index ["user_id"], name: "index_sites_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "site_checks", "sites"
end

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

ActiveRecord::Schema[7.0].define(version: 2024_11_28_000513) do
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

  create_table "notification_receipts", force: :cascade do |t|
    t.bigint "notification_id", null: false
    t.string "receipt_number", null: false
    t.string "status"
    t.datetime "sent_at"
    t.string "response_code"
    t.text "response_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notification_method", default: 0
    t.index ["notification_id"], name: "index_notification_receipts_on_notification_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "alert_type", default: 0, null: false
    t.string "threshold_value"
    t.integer "frequency", default: 0
    t.boolean "enabled", default: true, null: false
    t.integer "notification_method", default: 0
    t.string "uuid"
    t.datetime "last_notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notification_receipts_count", default: 0
    t.index ["user_id"], name: "index_notifications_on_user_id"
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

  create_table "plans", force: :cascade do |t|
    t.integer "name"
    t.decimal "price"
    t.text "features"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "monitor_sites", default: true
    t.boolean "notifications", default: true
    t.integer "max_sites", default: 0
    t.integer "ping_interval", default: 15
    t.boolean "detailed_reports", default: false
    t.boolean "priority_support", default: false
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
    t.string "url"
    t.integer "status", default: 0
    t.string "uuid", default: "7814d3ae-7419-4a1f-830e-2ae820fd5c44"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hostname"
  end

  create_table "user_sites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "site_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_user_sites_on_site_id"
    t.index ["user_id"], name: "index_user_sites_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "plan_id"
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "notification_receipts", "notifications"
  add_foreign_key "notifications", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "site_checks", "sites"
  add_foreign_key "user_sites", "sites"
  add_foreign_key "user_sites", "users"
end

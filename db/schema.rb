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

ActiveRecord::Schema[7.1].define(version: 2025_03_04_203447) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "application_settings", force: :cascade do |t|
    t.datetime "opendate", precision: nil
    t.integer "application_buffer"
    t.integer "contest_year"
    t.string "time_zone"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "allow_payments", default: false
    t.boolean "active_application", default: false, null: false
    t.boolean "allow_lottery_winner_emails", default: false, null: false
    t.boolean "allow_lottery_loser_emails", default: false, null: false
    t.decimal "registration_fee", default: "50.0", null: false
    t.integer "lottery_buffer", default: 50, null: false
    t.text "application_open_directions"
    t.text "application_closed_directions"
    t.integer "application_open_period", default: 48, null: false
    t.integer "lottery_result", array: true
    t.datetime "lottery_run_date", precision: nil
    t.text "registration_acceptance_directions"
    t.text "payments_directions"
    t.text "lottery_won_email"
    t.text "lottery_lost_email"
    t.integer "subscription_cost", default: 0, null: false
    t.text "subscription_directions"
    t.text "special_scholarship_acceptance_directions"
    t.text "application_confirm_email_message"
    t.text "balance_due_email_message"
    t.text "special_offer_invite_email"
  end

  create_table "applications", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "gender"
    t.integer "birth_year"
    t.string "street"
    t.string "street2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.string "phone"
    t.string "email"
    t.string "email_confirmation"
    t.string "workshop_selection1"
    t.string "workshop_selection2"
    t.string "workshop_selection3"
    t.string "lodging_selection"
    t.string "partner_registration_selection"
    t.string "partner_first_name"
    t.string "partner_last_name"
    t.string "how_did_you_hear"
    t.text "accessibility_requirements"
    t.text "special_lodging_request"
    t.text "food_restrictions"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "conf_year"
    t.integer "lottery_position"
    t.string "offer_status"
    t.boolean "result_email_sent", default: false, null: false
    t.datetime "offer_status_date", precision: nil
    t.boolean "subscription", default: false
    t.bigint "partner_registration_id", null: false
    t.index ["partner_registration_id"], name: "index_applications_on_partner_registration_id"
    t.index ["user_id"], name: "index_applications_on_user_id"
  end

  create_table "genders", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lodgings", force: :cascade do |t|
    t.string "plan"
    t.string "description"
    t.decimal "cost"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "partner_registrations", force: :cascade do |t|
    t.string "description"
    t.decimal "cost"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: true
  end

  create_table "payments", force: :cascade do |t|
    t.string "transaction_type"
    t.string "transaction_status"
    t.string "transaction_id"
    t.string "total_amount"
    t.string "transaction_date"
    t.string "account_type"
    t.string "result_code"
    t.string "result_message"
    t.string "user_account"
    t.string "payer_identity"
    t.string "timestamp"
    t.string "transaction_hash"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "conf_year"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workshops", force: :cascade do |t|
    t.string "instructor"
    t.string "last_name"
    t.string "first_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "applications", "partner_registrations"
  add_foreign_key "applications", "users"
  add_foreign_key "payments", "users"
end

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

ActiveRecord::Schema[8.1].define(version: 2026_08_04_220000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :serial, force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "application_settings", force: :cascade do |t|
    t.boolean "active_application", default: false, null: false
    t.boolean "allow_lottery_loser_emails", default: false, null: false
    t.boolean "allow_lottery_winner_emails", default: false, null: false
    t.boolean "allow_payments", default: false
    t.integer "application_buffer"
    t.text "application_closed_directions"
    t.text "application_confirm_email_message"
    t.text "application_open_directions"
    t.integer "application_open_period", default: 48, null: false
    t.text "balance_due_email_message"
    t.datetime "balance_due_emails_last_sent_at"
    t.integer "contest_year"
    t.datetime "created_at", precision: nil, null: false
    t.integer "lottery_buffer", default: 50, null: false
    t.text "lottery_lost_email"
    t.integer "lottery_result", array: true
    t.datetime "lottery_run_date", precision: nil
    t.text "lottery_won_email"
    t.datetime "opendate", precision: nil
    t.text "payments_directions"
    t.text "registration_acceptance_directions"
    t.decimal "registration_fee", default: "50.0", null: false
    t.text "special_offer_invite_email"
    t.text "special_scholarship_acceptance_directions"
    t.integer "subscription_cost", default: 0, null: false
    t.text "subscription_directions"
    t.string "time_zone"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "applications", force: :cascade do |t|
    t.text "accessibility_requirements"
    t.integer "birth_year"
    t.string "city"
    t.integer "conf_year"
    t.string "country"
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.string "email_confirmation"
    t.string "first_name"
    t.text "food_restrictions"
    t.string "gender"
    t.string "how_did_you_hear"
    t.string "last_name"
    t.string "lodging_selection"
    t.integer "lottery_position"
    t.string "offer_status"
    t.datetime "offer_status_date", precision: nil
    t.string "partner_first_name"
    t.string "partner_last_name"
    t.bigint "partner_registration_id", null: false
    t.string "partner_registration_selection"
    t.string "phone"
    t.boolean "result_email_sent", default: false, null: false
    t.text "special_lodging_request"
    t.string "state"
    t.string "street"
    t.string "street2"
    t.boolean "subscription", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.string "workshop_selection1"
    t.string "workshop_selection2"
    t.string "workshop_selection3"
    t.string "zip"
    t.index ["partner_registration_id"], name: "index_applications_on_partner_registration_id"
    t.index ["user_id"], name: "index_applications_on_user_id"
  end

  create_table "genders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lodgings", force: :cascade do |t|
    t.decimal "cost"
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.string "plan"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "partner_registrations", force: :cascade do |t|
    t.boolean "active", default: true
    t.decimal "cost"
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "payment_gateway_callbacks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", default: "receipt", null: false
    t.text "failure_reason"
    t.jsonb "payload", default: {}, null: false
    t.bigint "payment_id"
    t.string "processing_status", null: false
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["payment_id"], name: "index_payment_gateway_callbacks_on_payment_id"
    t.index ["processing_status"], name: "index_payment_gateway_callbacks_on_processing_status"
    t.index ["transaction_id"], name: "index_payment_gateway_callbacks_on_transaction_id"
    t.index ["user_id"], name: "index_payment_gateway_callbacks_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "account_type"
    t.integer "conf_year"
    t.datetime "created_at", precision: nil, null: false
    t.string "payer_identity"
    t.string "result_code"
    t.string "result_message"
    t.string "timestamp"
    t.string "total_amount"
    t.string "transaction_date"
    t.string "transaction_hash"
    t.string "transaction_id"
    t.string "transaction_status"
    t.string "transaction_type"
    t.datetime "updated_at", precision: nil, null: false
    t.string "user_account"
    t.bigint "user_id"
    t.index ["transaction_id"], name: "index_payments_on_transaction_id", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workshops", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", precision: nil, null: false
    t.string "first_name"
    t.string "instructor"
    t.string "last_name"
    t.datetime "updated_at", precision: nil, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "applications", "partner_registrations"
  add_foreign_key "applications", "users"
  add_foreign_key "payment_gateway_callbacks", "payments"
  add_foreign_key "payment_gateway_callbacks", "users"
  add_foreign_key "payments", "users"
end

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

ActiveRecord::Schema[7.0].define(version: 2023_02_01_223057) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "account_taxes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "sales_tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_taxes_on_account_id"
    t.index ["sales_tax_id"], name: "index_account_taxes_on_sales_tax_id"
  end

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "parent_account_id"
    t.string "classification"
    t.string "status"
    t.integer "reference"
    t.string "name"
    t.string "description"
    t.string "currency"
    t.decimal "starting_balance"
    t.decimal "current_balance"
    t.decimal "total_credit"
    t.decimal "total_debit"
    t.string "full_path"
    t.string "account_type"
    t.string "display_name"
    t.boolean "system", default: false
    t.string "internal_code"
    t.boolean "generated", default: false
    t.uuid "accountable_id"
    t.string "accountable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_accounts_on_organization_id"
    t.index ["parent_account_id"], name: "index_accounts_on_parent_account_id"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "addressable_id"
    t.string "addressable_type"
    t.string "line1"
    t.string "line2"
    t.string "city"
    t.string "state_or_province"
    t.string "country"
    t.string "zip_or_postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audit_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "integration_id", null: false
    t.uuid "organization_id", null: false
    t.uuid "user_id"
    t.uuid "auditable_id"
    t.string "auditable_type"
    t.datetime "occured_at"
    t.string "action"
    t.jsonb "current_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_id"], name: "index_audit_events_on_integration_id"
    t.index ["organization_id"], name: "index_audit_events_on_organization_id"
    t.index ["user_id"], name: "index_audit_events_on_user_id"
  end

  create_table "bank_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_credential_id"
    t.string "account_id"
    t.decimal "available_balance"
    t.decimal "current_balance"
    t.decimal "limit"
    t.string "iso_currency_code"
    t.string "unofficial_currency_code"
    t.string "mask"
    t.string "name"
    t.string "official_name"
    t.string "account_type"
    t.string "account_subtype"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_credential_id"], name: "index_bank_accounts_on_bank_credential_id"
  end

  create_table "bank_credentials", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.string "public_token"
    t.string "access_token"
    t.string "latest_cursor"
    t.string "institution_id"
    t.string "name"
    t.string "url"
    t.string "primary_color"
    t.text "logo"
    t.datetime "last_sync_at"
    t.string "status"
    t.string "error_type"
    t.string "error_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_bank_credentials_on_organization_id"
  end

  create_table "bank_transaction_rule_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_transaction_rule_id"
    t.uuid "bank_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_bank_transaction_rule_accounts_on_bank_account_id"
    t.index ["bank_transaction_rule_id"], name: "index_bank_trx_rule_accounts_on_bank_trx_rule_id"
  end

  create_table "bank_transaction_rule_conditions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_transaction_rule_id"
    t.string "field"
    t.string "condition"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_transaction_rule_id"], name: "index_bank_trx_rule_conditions_on_bank_trx_rule_id"
  end

  create_table "bank_transaction_rule_document_line_taxes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_transaction_rule_document_line_id"
    t.uuid "sales_tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_transaction_rule_document_line_id"], name: "index_bank_trx_rule_doc_line_taxes_on_bank_trx_rule_doc_line_id"
    t.index ["sales_tax_id"], name: "index_bank_transaction_rule_document_line_taxes_on_sales_tax_id"
  end

  create_table "bank_transaction_rule_document_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_transaction_rule_id"
    t.decimal "percentage"
    t.uuid "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_bank_transaction_rule_document_lines_on_account_id"
    t.index ["bank_transaction_rule_id"], name: "index_bank_trx_rule_document_lines_on_bank_trx_rule_id"
  end

  create_table "bank_transaction_rule_matches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "bank_transaction_id"
    t.uuid "bank_transaction_rule_id"
    t.string "matched_rule_internal_name"
    t.uuid "matched_document_id"
    t.string "matched_document_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_transaction_id"], name: "index_bank_transaction_rule_matches_on_bank_transaction_id"
    t.index ["bank_transaction_rule_id"], name: "index_bank_transaction_rule_matches_on_bank_transaction_rule_id"
    t.index ["organization_id"], name: "index_bank_transaction_rule_matches_on_organization_id"
  end

  create_table "bank_transaction_rules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.integer "priority"
    t.string "name"
    t.string "match_debit_or_credit"
    t.boolean "match_all_conditions"
    t.string "action"
    t.string "document_type"
    t.uuid "contact_id"
    t.boolean "auto_apply"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_bank_transaction_rules_on_contact_id"
    t.index ["organization_id"], name: "index_bank_transaction_rules_on_organization_id"
  end

  create_table "bank_transaction_transactionables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_transaction_id"
    t.uuid "transactionable_id"
    t.string "transactionable_type"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_transaction_id"], name: "index_bank_transaction_transactionables_on_bank_transaction_id"
  end

  create_table "bank_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id"
    t.string "account_id"
    t.string "transaction_id"
    t.string "category_id"
    t.string "payment_channel"
    t.string "name"
    t.string "merchant_name"
    t.decimal "debit"
    t.decimal "credit"
    t.string "iso_currency_code"
    t.string "unofficial_currency_code"
    t.date "date"
    t.datetime "datetime"
    t.date "authorized_date"
    t.datetime "authorized_datetime"
    t.boolean "pending"
    t.string "check_number"
    t.string "transaction_code"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_bank_transactions_on_bank_account_id"
  end

  create_table "business_units", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "parent_business_unit_id"
    t.string "name"
    t.string "description"
    t.string "full_path"
    t.boolean "system", default: false
    t.string "internal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_business_units_on_organization_id"
    t.index ["parent_business_unit_id"], name: "index_business_units_on_parent_business_unit_id"
  end

  create_table "commercial_document_line_taxes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "commercial_document_line_id"
    t.uuid "sales_tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commercial_document_line_id"], name: "idx_commercial_doc_line_taxes_on_commercial_doc_line_id"
    t.index ["sales_tax_id"], name: "index_commercial_document_line_taxes_on_sales_tax_id"
  end

  create_table "commercial_document_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "commercial_document_id"
    t.uuid "item_id"
    t.uuid "account_id"
    t.integer "order"
    t.string "description"
    t.decimal "quantity"
    t.decimal "unit_price"
    t.decimal "subtotal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_commercial_document_lines_on_account_id"
    t.index ["commercial_document_id"], name: "index_commercial_document_lines_on_commercial_document_id"
    t.index ["item_id"], name: "index_commercial_document_lines_on_item_id"
  end

  create_table "commercial_document_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "commercial_document_id"
    t.uuid "account_id"
    t.date "date"
    t.decimal "amount"
    t.string "currency"
    t.decimal "exchange_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_commercial_document_payments_on_account_id"
    t.index ["commercial_document_id"], name: "index_commercial_document_payments_on_commercial_document_id"
    t.index ["organization_id"], name: "index_commercial_document_payments_on_organization_id"
  end

  create_table "commercial_document_taxes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "commercial_document_id"
    t.uuid "sales_tax_id"
    t.boolean "calculate_from_rate"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commercial_document_id"], name: "index_commercial_document_taxes_on_commercial_document_id"
    t.index ["sales_tax_id"], name: "index_commercial_document_taxes_on_sales_tax_id"
  end

  create_table "commercial_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "contact_id"
    t.uuid "account_id"
    t.string "type"
    t.string "number"
    t.date "date"
    t.date "due_date"
    t.string "status"
    t.string "taxes_calculation"
    t.string "currency"
    t.decimal "exchange_rate"
    t.decimal "subtotal"
    t.decimal "taxes_amount"
    t.decimal "total"
    t.decimal "amount_paid"
    t.decimal "amount_due"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_commercial_documents_on_account_id"
    t.index ["contact_id"], name: "index_commercial_documents_on_contact_id"
    t.index ["organization_id"], name: "index_commercial_documents_on_organization_id"
  end

  create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.string "display_name"
    t.string "phone_number"
    t.string "email"
    t.string "website"
    t.string "currency"
    t.string "status"
    t.boolean "is_vendor"
    t.boolean "is_customer"
    t.boolean "is_employee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_contacts_on_organization_id"
  end

  create_table "integrations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "name"
    t.string "webhook_url"
    t.string "subscribed_webhooks", default: [], array: true
    t.text "secret_key_ciphertext"
    t.string "secret_key_bidx"
    t.boolean "system", default: false
    t.string "internal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_integrations_on_organization_id"
    t.index ["secret_key_bidx"], name: "index_integrations_on_secret_key_bidx", unique: true
  end

  create_table "items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "name"
    t.string "ugs"
    t.string "cup"
    t.string "status"
    t.boolean "sell", default: false
    t.uuid "income_account_id"
    t.string "sell_description"
    t.decimal "sell_price"
    t.boolean "buy", default: false
    t.uuid "expense_account_id"
    t.string "buy_description"
    t.decimal "buy_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_account_id"], name: "index_items_on_expense_account_id"
    t.index ["income_account_id"], name: "index_items_on_income_account_id"
    t.index ["organization_id"], name: "index_items_on_organization_id"
  end

  create_table "journal_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "integration_id"
    t.uuid "journalable_id"
    t.string "journalable_type"
    t.string "integration_journalable_type"
    t.string "integration_journalable_id"
    t.string "narration"
    t.date "date"
    t.string "currency"
    t.decimal "exchange_rate"
    t.decimal "total_credit"
    t.decimal "total_debit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_id"], name: "index_journal_entries_on_integration_id"
    t.index ["organization_id"], name: "index_journal_entries_on_organization_id"
  end

  create_table "journal_entry_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "journal_entry_id"
    t.uuid "account_id"
    t.uuid "contact_id"
    t.uuid "business_unit_id"
    t.decimal "credit"
    t.decimal "debit"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_journal_entry_lines_on_account_id"
    t.index ["business_unit_id"], name: "index_journal_entry_lines_on_business_unit_id"
    t.index ["contact_id"], name: "index_journal_entry_lines_on_contact_id"
    t.index ["journal_entry_id"], name: "index_journal_entry_lines_on_journal_entry_id"
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "organization_id", null: false
    t.string "level"
    t.datetime "confirmed_at"
    t.datetime "last_logged_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.datetime "setup_completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "outgoing_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.string "recipients", default: [], array: true
    t.string "title"
    t.string "subject"
    t.text "body"
    t.uuid "related_object_id"
    t.string "related_object_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_outgoing_emails_on_organization_id"
  end

  create_table "permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "role_id"
    t.uuid "business_unit_id"
    t.string "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_unit_id"], name: "index_permissions_on_business_unit_id"
    t.index ["organization_id"], name: "index_permissions_on_organization_id"
    t.index ["role_id"], name: "index_permissions_on_role_id"
  end

  create_table "recurring_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "recurrable_id"
    t.string "recurrable_type"
    t.string "frequency"
    t.string "end_repeat"
    t.date "repeat_until"
    t.integer "repeat_count"
    t.integer "interval"
    t.integer "day_of_week", default: [], array: true
    t.integer "day_of_month", default: [], array: true
    t.integer "day_of_year", default: [], array: true
    t.integer "month_of_year", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_recurring_events_on_organization_id"
  end

  create_table "role_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "role_id"
    t.uuid "membership_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_role_members_on_membership_id"
    t.index ["role_id"], name: "index_role_members_on_role_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_roles_on_organization_id"
  end

  create_table "sales_taxes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "name"
    t.string "abbreviation"
    t.string "number"
    t.decimal "rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_sales_taxes_on_organization_id"
  end

  create_table "transfers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id"
    t.uuid "from_account_id"
    t.uuid "to_account_id"
    t.date "date"
    t.decimal "amount"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_account_id"], name: "index_transfers_on_from_account_id"
    t.index ["organization_id"], name: "index_transfers_on_organization_id"
    t.index ["to_account_id"], name: "index_transfers_on_to_account_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "sign_in_count", default: 0, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "first_name"
    t.string "last_name"
    t.datetime "setup_completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "account_taxes", "accounts"
  add_foreign_key "account_taxes", "sales_taxes"
  add_foreign_key "accounts", "accounts", column: "parent_account_id"
  add_foreign_key "accounts", "organizations"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_events", "integrations"
  add_foreign_key "audit_events", "organizations"
  add_foreign_key "audit_events", "users"
  add_foreign_key "bank_accounts", "bank_credentials"
  add_foreign_key "bank_credentials", "organizations"
  add_foreign_key "bank_transaction_rule_accounts", "bank_accounts"
  add_foreign_key "bank_transaction_rule_accounts", "bank_transaction_rules"
  add_foreign_key "bank_transaction_rule_conditions", "bank_transaction_rules"
  add_foreign_key "bank_transaction_rule_document_line_taxes", "bank_transaction_rule_document_lines"
  add_foreign_key "bank_transaction_rule_document_line_taxes", "sales_taxes"
  add_foreign_key "bank_transaction_rule_document_lines", "accounts"
  add_foreign_key "bank_transaction_rule_document_lines", "bank_transaction_rules"
  add_foreign_key "bank_transaction_rule_matches", "bank_transaction_rules"
  add_foreign_key "bank_transaction_rule_matches", "bank_transactions"
  add_foreign_key "bank_transaction_rule_matches", "organizations"
  add_foreign_key "bank_transaction_rules", "contacts"
  add_foreign_key "bank_transaction_rules", "organizations"
  add_foreign_key "bank_transaction_transactionables", "bank_transactions"
  add_foreign_key "bank_transactions", "bank_accounts"
  add_foreign_key "business_units", "business_units", column: "parent_business_unit_id"
  add_foreign_key "business_units", "organizations"
  add_foreign_key "commercial_document_line_taxes", "commercial_document_lines"
  add_foreign_key "commercial_document_line_taxes", "sales_taxes"
  add_foreign_key "commercial_document_lines", "accounts"
  add_foreign_key "commercial_document_lines", "commercial_documents"
  add_foreign_key "commercial_document_lines", "items"
  add_foreign_key "commercial_document_payments", "accounts"
  add_foreign_key "commercial_document_payments", "commercial_documents"
  add_foreign_key "commercial_document_payments", "organizations"
  add_foreign_key "commercial_document_taxes", "commercial_documents"
  add_foreign_key "commercial_document_taxes", "sales_taxes"
  add_foreign_key "commercial_documents", "accounts"
  add_foreign_key "commercial_documents", "contacts"
  add_foreign_key "commercial_documents", "organizations"
  add_foreign_key "contacts", "organizations"
  add_foreign_key "integrations", "organizations"
  add_foreign_key "items", "accounts", column: "expense_account_id"
  add_foreign_key "items", "accounts", column: "income_account_id"
  add_foreign_key "items", "organizations"
  add_foreign_key "journal_entries", "integrations"
  add_foreign_key "journal_entries", "organizations"
  add_foreign_key "journal_entry_lines", "accounts"
  add_foreign_key "journal_entry_lines", "business_units"
  add_foreign_key "journal_entry_lines", "contacts"
  add_foreign_key "journal_entry_lines", "journal_entries"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "outgoing_emails", "organizations"
  add_foreign_key "permissions", "business_units"
  add_foreign_key "permissions", "organizations"
  add_foreign_key "permissions", "roles"
  add_foreign_key "recurring_events", "organizations"
  add_foreign_key "role_members", "memberships"
  add_foreign_key "role_members", "roles"
  add_foreign_key "roles", "organizations"
  add_foreign_key "sales_taxes", "organizations"
  add_foreign_key "transfers", "accounts", column: "from_account_id"
  add_foreign_key "transfers", "accounts", column: "to_account_id"
  add_foreign_key "transfers", "organizations"
end

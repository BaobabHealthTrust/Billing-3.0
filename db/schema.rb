# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170724121032) do

  create_table "medical_scheme_providers", primary_key: "scheme_provider_id", force: :cascade do |t|
    t.string   "company_name",    limit: 255
    t.string   "company_address", limit: 255
    t.string   "phone_number_1",  limit: 255
    t.string   "phone_number_2",  limit: 255
    t.string   "email_address",   limit: 255
    t.integer  "creator",         limit: 4,                   null: false
    t.boolean  "retired",                     default: false, null: false
    t.integer  "retired_by",      limit: 4
    t.string   "retired_reason",  limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "medical_schemes", primary_key: "medical_scheme_id", force: :cascade do |t|
    t.string   "name",                    limit: 255,                 null: false
    t.integer  "medical_scheme_provider", limit: 4,                   null: false
    t.integer  "creator",                 limit: 4,                   null: false
    t.boolean  "retired",                             default: false, null: false
    t.integer  "retired_by",              limit: 4
    t.string   "retired_reason",          limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "order_entries", primary_key: "order_entry_id", force: :cascade do |t|
    t.integer  "patient_id",    limit: 4,                   null: false
    t.integer  "service_id",    limit: 4,                   null: false
    t.datetime "order_date",                                null: false
    t.float    "quantity",      limit: 24,  default: 0.0,   null: false
    t.float    "full_price",    limit: 24,  default: 0.0,   null: false
    t.float    "amount_paid",   limit: 24,  default: 0.0,   null: false
    t.integer  "cashier",       limit: 4,                   null: false
    t.integer  "location",      limit: 4
    t.boolean  "voided",                    default: false
    t.integer  "voided_by",     limit: 4
    t.string   "voided_reason", limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "order_payments", primary_key: "order_payment_id", force: :cascade do |t|
    t.string   "receipt_number", limit: 255,                 null: false
    t.integer  "order_entry_id", limit: 4,                   null: false
    t.float    "amount",         limit: 24,  default: 0.0
    t.integer  "cashier",        limit: 4,                   null: false
    t.boolean  "voided",                     default: false
    t.integer  "voided_by",      limit: 4
    t.string   "voided_reason",  limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "patient_accounts", primary_key: "account_id", force: :cascade do |t|
    t.integer  "patient_id",        limit: 4,                null: false
    t.integer  "medical_scheme_id", limit: 4,                null: false
    t.date     "active_from"
    t.boolean  "active",                      default: true
    t.integer  "creator",           limit: 4,                null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "receipts", force: :cascade do |t|
    t.integer  "patient_id",     limit: 4
    t.string   "receipt_number", limit: 255,                  null: false
    t.datetime "payment_stamp"
    t.string   "payment_mode",   limit: 255, default: "CASH", null: false
    t.integer  "cashier",        limit: 4,                    null: false
    t.boolean  "voided",                     default: false
    t.integer  "voided_by",      limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "service_panel_details", primary_key: "panel_detail_id", force: :cascade do |t|
    t.integer  "service_panel_id", limit: 4
    t.integer  "service_id",       limit: 4
    t.float    "quantity",         limit: 24
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "service_panels", primary_key: "service_panel_id", force: :cascade do |t|
    t.string   "name",            limit: 255,                 null: false
    t.integer  "service_type_id", limit: 4,                   null: false
    t.integer  "creator",         limit: 4,                   null: false
    t.boolean  "voided",                      default: false
    t.integer  "voided_by",       limit: 4
    t.string   "voided_reason",   limit: 255
    t.date     "voided_date"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "service_price_histories", primary_key: "price_history_id", force: :cascade do |t|
    t.integer  "service_id",  limit: 4,                 null: false
    t.float    "price",       limit: 24,  default: 0.0, null: false
    t.string   "price_type",  limit: 255,               null: false
    t.date     "active_from",                           null: false
    t.date     "active_to",                             null: false
    t.integer  "creator",     limit: 4,                 null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "service_prices", primary_key: "price_id", force: :cascade do |t|
    t.integer  "service_id",  limit: 4,                   null: false
    t.float    "price",       limit: 24,  default: 0.0,   null: false
    t.string   "price_type",  limit: 255,                 null: false
    t.integer  "creator",     limit: 4,                   null: false
    t.integer  "updated_by",  limit: 4,                   null: false
    t.boolean  "voided",                  default: false
    t.date     "voided_date"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "service_types", primary_key: "service_type_id", force: :cascade do |t|
    t.string   "name",           limit: 255,                 null: false
    t.integer  "creator",        limit: 4,                   null: false
    t.boolean  "retired",                    default: false, null: false
    t.integer  "retired_by",     limit: 4
    t.string   "retired_reason", limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "services", primary_key: "service_id", force: :cascade do |t|
    t.string   "name",            limit: 255,                 null: false
    t.integer  "service_type_id", limit: 4,                   null: false
    t.string   "unit",            limit: 255
    t.integer  "rank",            limit: 4,   default: 999,   null: false
    t.integer  "creator",         limit: 4,                   null: false
    t.boolean  "voided",                      default: false
    t.integer  "voided_by",       limit: 4
    t.string   "voided_reason",   limit: 255
    t.date     "voided_date"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

end

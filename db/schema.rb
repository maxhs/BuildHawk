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

ActiveRecord::Schema.define(version: 20131221185622) do

  create_table "addresses", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "company_id"
    t.string   "state",        default: ""
    t.boolean  "active"
    t.string   "street1",      default: ""
    t.string   "street2",      default: ""
    t.string   "city",         default: ""
    t.string   "phone_number", default: ""
    t.string   "zip",          default: ""
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["user_id", "company_id", "project_id"], name: "addresses_ix"

  create_table "apn_registrations", force: true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apn_registrations", ["user_id"], name: "apn_registrations_user_id_ix"

  create_table "categories", force: true do |t|
    t.integer  "order_index"
    t.integer  "checklist_id"
    t.integer  "core_checklist_id"
    t.datetime "completed_date"
    t.datetime "milestone_date"
    t.integer  "checklist_items_count"
    t.integer  "subcategories_count"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  add_index "categories", ["checklist_id"], name: "categories_checklist_id_ix"

  create_table "checklist_items", force: true do |t|
    t.string   "status"
    t.string   "item_type"
    t.text     "body"
    t.integer  "order_index"
    t.integer  "item_index"
    t.integer  "subcategory_id"
    t.integer  "category_id"
    t.integer  "checklist_id"
    t.integer  "completed_by_user_id"
    t.datetime "critical_date"
    t.datetime "milestone_date"
    t.datetime "completed_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "checklist_items", ["subcategory_id", "checklist_id"], name: "checklist_items_ix"

  create_table "checklists", force: true do |t|
    t.integer  "project_id"
    t.integer  "company_id"
    t.string   "name"
    t.datetime "completed_date"
    t.datetime "milestone_date"
    t.integer  "checklist_items_count"
    t.boolean  "core",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "checklists", ["project_id", "company_id"], name: "checklists_ix"

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "report_id"
    t.integer  "punchlist_item_id"
    t.integer  "checklist_item_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["user_id", "report_id", "checklist_item_id", "punchlist_item_id"], name: "comments_ix"

  create_table "companies", force: true do |t|
    t.string   "name",               default: "", null: false
    t.string   "email"
    t.string   "phone_number"
    t.boolean  "pre_register"
    t.string   "contact_name"
    t.integer  "projects_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "photos", force: true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "report_id"
    t.integer  "punchlist_item_id"
    t.integer  "checklist_item_id"
    t.string   "phase"
    t.string   "name",               default: ""
  end

  add_index "photos", ["report_id", "checklist_item_id", "punchlist_item_id", "user_id"], name: "photos_ix"

  create_table "project_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_users", ["project_id", "user_id"], name: "project_users_ix"

  create_table "projects", force: true do |t|
    t.boolean  "active",       default: true
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "checklist_id"
    t.boolean  "core",         default: false
  end

  add_index "projects", ["company_id"], name: "projects_company_id_ix"

  create_table "punchlist_items", force: true do |t|
    t.text     "body"
    t.integer  "punchlist_id"
    t.integer  "user_id"
    t.string   "location"
    t.integer  "order_index"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignee_id"
    t.boolean  "completed",            default: false
    t.datetime "completed_at"
    t.integer  "completed_by_user_id"
    t.string   "assignee_name"
  end

  add_index "punchlist_items", ["assignee_id"], name: "punchlist_items_assignee_id_ix"

  create_table "punchlists", force: true do |t|
    t.boolean  "worklist",   default: false
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_fields", force: true do |t|
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_users", force: true do |t|
    t.integer  "report_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", force: true do |t|
    t.string   "title"
    t.string   "body"
    t.integer  "project_id"
    t.integer  "author_id"
    t.string   "report_type"
    t.text     "weather"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports", ["author_id", "project_id"], name: "reports_ix"

  create_table "subcategories", force: true do |t|
    t.integer  "category_id"
    t.string   "name"
    t.integer  "order_index"
    t.integer  "checklist_items_count"
    t.datetime "completed_date"
    t.datetime "milestone_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  add_index "subcategories", ["category_id"], name: "subcategories_category_id_ix"

  create_table "subs", force: true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.string   "email"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "first_name",             default: ""
    t.string   "last_name",              default: ""
    t.string   "full_name",              default: ""
    t.string   "phone_number",           default: ""
    t.boolean  "admin",                  default: false
    t.boolean  "uber_admin",             default: false
    t.string   "authentication_token"
    t.boolean  "push_permissions",       default: true
    t.boolean  "email_permissions",      default: true
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "active",                 default: true
  end

  add_index "users", ["company_id"], name: "users_company_id_ix"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end

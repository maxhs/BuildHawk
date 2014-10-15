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

ActiveRecord::Schema.define(version: 20141015224101) do

  create_table "activities", force: true do |t|
    t.integer  "report_id"
    t.integer  "user_id"
    t.integer  "checklist_item_id"
    t.integer  "task_id"
    t.integer  "project_id"
    t.integer  "comment_id"
    t.integer  "message_id"
    t.integer  "photo_id"
    t.text     "body"
    t.string   "activity_type"
    t.boolean  "hidden",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["user_id", "project_id", "report_id", "task_id", "comment_id", "checklist_item_id", "message_id"], name: "activities_idxs"

  create_table "addresses", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "company_id"
    t.string   "state",      default: ""
    t.boolean  "active"
    t.string   "street1",    default: ""
    t.string   "street2",    default: ""
    t.string   "city",       default: ""
    t.string   "phone",      default: ""
    t.string   "zip",        default: ""
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["user_id", "company_id", "project_id"], name: "addresses_idx"

  create_table "alternates", force: true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alternates", ["user_id"], name: "alternates_idx"

  create_table "billing_days", force: true do |t|
    t.integer  "project_user_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "billing_days", ["project_user_id", "company_id"], name: "billing_days_idx"

  create_table "cards", force: true do |t|
    t.string   "last4"
    t.string   "exp_month"
    t.string   "exp_year"
    t.integer  "company_id"
    t.text     "card_id"
    t.string   "brand"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip"
    t.string   "country"
    t.string   "name"
    t.boolean  "active",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.integer  "phase_id"
    t.string   "name"
    t.integer  "order_index"
    t.integer  "checklist_items_count"
    t.datetime "completed_date"
    t.datetime "milestone_date"
    t.integer  "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["phase_id"], name: "categories_phase_id_idx"

  create_table "charges", force: true do |t|
    t.integer  "company_id"
    t.boolean  "paid",        default: false
    t.text     "description", default: ""
    t.string   "promo_code",  default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_items", force: true do |t|
    t.integer  "state"
    t.string   "item_type"
    t.text     "body"
    t.integer  "order_index"
    t.integer  "phase_id"
    t.integer  "category_id"
    t.integer  "checklist_id"
    t.integer  "user_id"
    t.integer  "completed_by_user_id"
    t.datetime "critical_date"
    t.datetime "milestone_date"
    t.datetime "completed_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photos_count"
    t.integer  "comments_count"
  end

  add_index "checklist_items", ["category_id", "checklist_id"], name: "checklist_items_idx"
  add_index "checklist_items", ["category_id"], name: "checklist_item_category_id_ix"
  add_index "checklist_items", ["checklist_id"], name: "checklist_item_checklist_id_ix"
  add_index "checklist_items", ["phase_id"], name: "checklist_item_phase_id_ix"

  create_table "checklists", force: true do |t|
    t.integer  "project_id"
    t.integer  "company_id"
    t.string   "name"
    t.datetime "completed_date"
    t.datetime "milestone_date"
    t.integer  "checklist_items_count"
    t.boolean  "core",                  default: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "checklists", ["project_id", "company_id"], name: "checklists_idx"

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "report_id"
    t.integer  "checklist_item_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "task_id"
    t.boolean  "mobile",            default: false
    t.integer  "message_id"
  end

  add_index "comments", ["user_id", "report_id", "checklist_item_id", "task_id"], name: "comments_idx"

  create_table "companies", force: true do |t|
    t.string   "name",               default: "",    null: false
    t.string   "email"
    t.string   "phone"
    t.boolean  "pre_register"
    t.string   "contact_name"
    t.integer  "projects_count"
    t.boolean  "active"
    t.string   "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "valid_billing",      default: false
  end

  create_table "company_subs", force: true do |t|
    t.integer  "company_id"
    t.integer  "subcontractor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "folders", force: true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leads", force: true do |t|
    t.string   "name"
    t.string   "company_name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_projects", force: true do |t|
    t.integer  "message_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_users", force: true do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.boolean  "sent",       default: false
    t.boolean  "read",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",   default: false
  end

  add_index "message_users", ["user_id", "message_id"], name: "message_users_idx"

  create_table "messages", force: true do |t|
    t.integer  "author_id"
    t.integer  "company_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["author_id", "company_id"], name: "messages_idx"

  create_table "notifications", force: true do |t|
    t.boolean  "read",              default: false
    t.boolean  "sent",              default: false
    t.integer  "user_id"
    t.integer  "report_id"
    t.integer  "task_id"
    t.integer  "project_id"
    t.integer  "comment_id"
    t.integer  "checklist_item_id"
    t.text     "body"
    t.string   "notification_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "feed",              default: false
    t.integer  "message_id"
  end

  create_table "phases", force: true do |t|
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
  end

  add_index "phases", ["checklist_id"], name: "phases_checklist_id_idx"
  add_index "phases", ["core_checklist_id"], name: "phase_core_checklist_idx"

  create_table "photos", force: true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "comment_id"
    t.string   "name",                                     null: false
    t.string   "phase"
    t.string   "source",             default: "Documents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "report_id"
    t.integer  "task_id"
    t.integer  "checklist_item_id"
    t.integer  "folder_id"
    t.boolean  "mobile",             default: false
    t.text     "description"
    t.datetime "taken_at"
  end

  add_index "photos", ["folder_id"], name: "photos_folder_idx"
  add_index "photos", ["report_id", "checklist_item_id", "task_id", "user_id"], name: "photos_idx"

  create_table "project_groups", force: true do |t|
    t.integer  "company_id"
    t.string   "name",           default: ""
    t.integer  "projects_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_subs", force: true do |t|
    t.integer  "project_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",           default: false
    t.boolean  "core",             default: false
    t.integer  "project_group_id"
    t.integer  "company_id"
  end

  add_index "project_users", ["project_id", "user_id"], name: "project_users_idx"

  create_table "projects", force: true do |t|
    t.boolean  "active",           default: true
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "checklist_id"
    t.boolean  "core",             default: false
    t.integer  "project_group_id"
    t.boolean  "hidden",           default: false
    t.integer  "order_index",      default: 0
  end

  add_index "projects", ["company_id"], name: "projects_company_id_idx"

  create_table "push_tokens", force: true do |t|
    t.integer  "user_id"
    t.text     "token"
    t.integer  "device_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "push_tokens", ["user_id"], name: "apn_registrations_user_id_idx"

  create_table "reminders", force: true do |t|
    t.integer  "user_id"
    t.integer  "checklist_item_id"
    t.integer  "task_id"
    t.integer  "project_id"
    t.datetime "reminder_datetime"
    t.boolean  "email"
    t.boolean  "text"
    t.boolean  "push"
    t.boolean  "active",            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reminders", ["user_id", "checklist_item_id", "task_id", "project_id"], name: "reminders_idx"

  create_table "report_companies", force: true do |t|
    t.integer  "report_id"
    t.integer  "company_id"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_fields", force: true do |t|
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "report_topics", force: true do |t|
    t.integer  "safety_topic_id"
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "report_topics", ["report_id", "safety_topic_id"], name: "report_topics_idx"

  create_table "report_users", force: true do |t|
    t.integer  "report_id"
    t.integer  "user_id"
    t.float    "hours"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "project_id"
    t.integer  "author_id"
    t.string   "report_type"
    t.text     "weather"
    t.string   "humidity"
    t.string   "precip_accumulation"
    t.string   "precip"
    t.string   "date_string"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "weather_icon"
    t.string   "temp"
    t.string   "wind"
    t.boolean  "mobile",              default: false
  end

  add_index "reports", ["author_id", "project_id"], name: "reports_idx"

  create_table "safety_topics", force: true do |t|
    t.integer  "company_id"
    t.string   "title"
    t.text     "info"
    t.boolean  "core",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasklists", force: true do |t|
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasklists", ["project_id"], name: "taskslists_idx"

  create_table "tasks", force: true do |t|
    t.text     "body"
    t.integer  "tasklist_id"
    t.integer  "assignee_id"
    t.string   "location"
    t.integer  "order_index"
    t.string   "assignee_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed",            default: false
    t.datetime "completed_at"
    t.integer  "completed_by_user_id"
    t.integer  "photos_count"
    t.integer  "comments_count"
    t.boolean  "mobile",               default: false
    t.integer  "user_id"
  end

  add_index "tasks", ["assignee_id"], name: "tasks_assignee_id_idx"
  add_index "tasks", ["tasklist_id", "assignee_id", "completed_by_user_id"], name: "tasks_idx"

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "first_name",             default: ""
    t.string   "last_name",              default: ""
    t.string   "full_name",              default: ""
    t.string   "phone",                  default: ""
    t.boolean  "admin",                  default: false
    t.boolean  "company_admin",          default: false
    t.boolean  "uber_admin",             default: false
    t.string   "authentication_token"
    t.boolean  "push_permissions",       default: true
    t.boolean  "email_permissions",      default: true
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "company_id"
    t.boolean  "active",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "text_permissions",       default: true
  end

  add_index "users", ["company_id"], name: "users_company_id_idx"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end

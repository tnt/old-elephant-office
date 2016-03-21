# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101214213514) do

  create_table "address_specifics", :force => true do |t|
    t.integer "address_id"
    t.string  "line2",            :limit => 60
    t.string  "line3",            :limit => 60
    t.string  "street",           :limit => 60
    t.string  "number",           :limit => 5
    t.string  "zip",              :limit => 10
    t.string  "city",             :limit => 20
    t.string  "country",          :limit => 20
    t.string  "state",            :limit => 20
    t.boolean "delivery_address",               :default => false, :null => false
    t.boolean "invoice_address",                :default => false, :null => false
  end

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "contactables", :force => true do |t|
    t.string   "sex"
    t.string   "name"
    t.string   "firstname"
    t.text     "remark"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "outdated",                  :default => false, :null => false
    t.string   "title"
    t.string   "type",        :limit => 20,                    :null => false
    t.string   "kagge",       :limit => 10,                    :null => false
  end

  create_table "contents", :force => true do |t|
    t.integer  "paper_id"
    t.integer  "position"
    t.string   "kind"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "template_item", :default => false, :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "asshole",    :default => false, :null => false
  end

  create_table "documents", :force => true do |t|
    t.integer  "address_id"
    t.integer  "based_on"
    t.datetime "date"
    t.decimal  "value",            :precision => 22, :scale => 12
    t.text     "remark"
    t.string   "kind"
    t.integer  "user_id"
    t.integer  "last_modified_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                            :default => "open"
    t.integer  "signed_by"
    t.float    "scale",                                            :default => 0.5,    :null => false
    t.integer  "invoice_number"
    t.text     "subject"
    t.float    "tax_rate",                                         :default => 19.0
    t.string   "type"
    t.text     "message"
    t.string   "message_id"
    t.boolean  "sent",                                             :default => false
    t.boolean  "is_foreign",                                       :default => false,  :null => false
    t.date     "realization_from"
    t.date     "realization_to"
  end

  create_table "documents_documents", :force => true do |t|
    t.integer "linker_id"
    t.integer "linkee_id"
  end

  add_index "documents_documents", ["linkee_id"], :name => "linkee_id"
  add_index "documents_documents", ["linker_id"], :name => "linker_id"

  create_table "email_address_specifics", :force => true do |t|
    t.integer "email_address_id"
    t.string  "email",            :limit => 50
  end

  create_table "email_attachments", :force => true do |t|
    t.integer "email_id"
    t.string  "file_name"
    t.string  "kind"
    t.integer "paper_id"
    t.integer "position"
  end

  create_table "invoice_numbers", :force => true do |t|
    t.integer "year",                               :null => false
    t.integer "number", :limit => 2, :default => 0
  end

  create_table "person_specifics", :force => true do |t|
    t.integer "person_id"
  end

  create_table "phone_number_specifics", :force => true do |t|
    t.integer "phone_number_id"
    t.string  "number",          :limit => 50
    t.string  "kind",            :limit => 10
    t.string  "norm_number"
  end

  create_table "rblock_lines", :force => true do |t|
    t.integer  "content_id"
    t.integer  "position"
    t.text     "text"
    t.decimal  "price",      :precision => 22, :scale => 12
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind",                                       :default => "line", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.string   "name"
    t.string   "gname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "signature"
    t.boolean  "admin",      :default => false, :null => false
    t.boolean  "system",     :default => false, :null => false
  end

end

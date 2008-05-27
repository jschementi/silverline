# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 3) do

  create_table "answers", :force => true do |t|
    t.string   "value"
    t.boolean  "is_correct"
    t.text     "incorrect_message"
    t.integer  "problem_id"
    t.integer  "media_id"
    t.integer  "position"
    t.datetime "deleted_at"
    t.integer  "version"
  end

  create_table "assistments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.integer  "position"
    t.datetime "deleted_at"
    t.integer  "version"
  end

  create_table "hints", :force => true do |t|
    t.text     "value"
    t.integer  "media_id"
    t.integer  "problem_id"
    t.integer  "position"
    t.datetime "deleted_at"
    t.integer  "version"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "problem_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "deleted_at"
  end

  create_table "problems", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.integer  "media_id"
    t.integer  "problem_type_id"
    t.integer  "answer_sorting_type_id"
    t.integer  "assistment_id"
    t.integer  "scaffold_id"
    t.integer  "position"
    t.datetime "deleted_at"
    t.integer  "version"
  end

  create_table "scaffolds", :force => true do |t|
    t.string   "name"
    t.integer  "problem_id"
    t.boolean  "enabled"
    t.datetime "deleted_at"
    t.integer  "version"
  end

end

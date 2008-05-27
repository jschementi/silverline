class Assistment < ActiveRecord::Migration
  def self.up
    create_table "answers" do |t|
      t.string   "value"
      t.boolean  "is_correct"
      t.text     "incorrect_message"
      t.integer  "problem_id"
      t.integer  "media_id"
      t.integer  "position"
      t.datetime "deleted_at"
      t.integer  "version"
    end
    
    create_table "assistments" do |t|
      t.string   "name"
      t.text     "description"
      t.datetime "created_at"
      t.integer  "position"
      t.datetime "deleted_at"
      t.integer  "version"
    end
    
    create_table "hints" do |t|
      t.text     "value"
      t.integer  "media_id"
      t.integer  "problem_id"
      t.integer  "position"
      t.datetime "deleted_at"
      t.integer  "version"
    end
    
    create_table "problem_types" do |t|
      t.string   "name"
      t.string   "description"
      t.datetime "deleted_at"
    end
    
    create_table "problems" do |t|
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
    
    create_table "scaffolds" do |t|
      t.string   "name"
      t.integer  "problem_id"
      t.boolean  "enabled"
      t.datetime "deleted_at"
      t.integer  "version"
    end
  end
  
  def self.down
    drop_table :assistments
    drop_table :problems
    drop_table :problem_types
    drop_table :scaffolds
    drop_table :hints
    drop_table :answers
  end
end

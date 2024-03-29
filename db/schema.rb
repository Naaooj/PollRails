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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110515165114) do

  create_table "answers", :primary_key => "answer_id", :force => true do |t|
    t.string   "answer",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_id"
  end

  create_table "surveys", :primary_key => "survey_id", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     :null => false
    t.text     "title",       :null => false
    t.text     "description", :null => false
    t.datetime "end_at"
  end

  create_table "users", :primary_key => "user_id", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "username",   :null => false
    t.text     "password",   :null => false
    t.text     "email",      :null => false
    t.text     "provider"
    t.text     "uid"
  end

  create_table "votes", :primary_key => "vote_id", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "answer_id",  :null => false
    t.integer  "user_id",    :null => false
  end

end

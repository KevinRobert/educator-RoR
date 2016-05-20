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

ActiveRecord::Schema.define(version: 20160428141535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.integer  "question_id"
    t.string   "value"
    t.string   "options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "subject"
    t.string   "topic"
    t.string   "question_type"
    t.string   "difficulty"
    t.text     "question"
    t.string   "option1"
    t.string   "option2"
    t.string   "option3"
    t.string   "option4"
    t.string   "concepts"
    t.string   "answer_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "timed"
    t.integer  "timeout"
    t.string   "image_temp_name"
    t.string   "description_title"
    t.text     "description"
    t.text     "solution_description"
    t.string   "grade"
    t.string   "syllabus"
  end

  create_table "schools", force: :cascade do |t|
    t.string   "name"
    t.boolean  "grade6"
    t.boolean  "grade7"
    t.boolean  "grade8"
    t.boolean  "grade9"
    t.boolean  "grade10"
    t.boolean  "grade11"
    t.boolean  "grade12"
    t.string   "address1"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.integer  "admin_id"
    t.boolean  "active",     default: true
    t.string   "pin_code"
  end

  create_table "section_tests", force: :cascade do |t|
    t.integer  "section_id"
    t.integer  "test_id"
    t.datetime "start_at"
    t.datetime "end_at"
  end

  create_table "sections", force: :cascade do |t|
    t.integer "school_id"
    t.string  "name"
    t.string  "grade"
  end

  create_table "syllabuses", force: :cascade do |t|
    t.string "syllabus"
    t.string "grade"
    t.string "subject"
    t.string "topic"
  end

  create_table "test_questions", force: :cascade do |t|
    t.integer  "test_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "si_no"
    t.integer  "position"
  end

  add_index "test_questions", ["question_id"], name: "index_test_questions_on_question_id", using: :btree
  add_index "test_questions", ["test_id"], name: "index_test_questions_on_test_id", using: :btree

  create_table "test_responses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "test_id"
    t.integer  "question_id"
    t.string   "answer_options"
    t.string   "answer_value"
    t.float    "answer_time"
    t.float    "answer_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_test_id"
  end

  add_index "test_responses", ["question_id"], name: "index_test_responses_on_question_id", using: :btree
  add_index "test_responses", ["test_id"], name: "index_test_responses_on_test_id", using: :btree
  add_index "test_responses", ["user_id"], name: "index_test_responses_on_user_id", using: :btree

  create_table "tests", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject"
    t.integer  "timeout"
    t.text     "description"
    t.string   "syllabus"
    t.string   "topic"
    t.string   "grade"
    t.boolean  "allow_retry", default: true
    t.string   "report_by",   default: "Topic"
  end

  create_table "user_tests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "test_id"
    t.string   "status"
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_questions"
    t.integer  "correct_answers"
    t.integer  "time"
    t.string   "random_order"
  end

  add_index "user_tests", ["test_id"], name: "index_user_tests_on_test_id", using: :btree
  add_index "user_tests", ["user_id"], name: "index_user_tests_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "role"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.boolean  "active",                 default: true
    t.string   "grade"
    t.integer  "school_id"
    t.integer  "section_id"
    t.string   "username"
    t.string   "contact_email"
  end

  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end

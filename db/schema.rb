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

ActiveRecord::Schema.define(version: 20180206163318) do

  create_table "content_fragments", force: :cascade do |t|
    t.string "book"
    t.string "html"
    t.string "chapter"
    t.string "heading", default: "<table><tr><td></td></tr></table>"
    t.string "locale"
    t.string "chapter_padded"
    t.boolean "is_published", default: false
    t.index ["chapter_padded"], name: "index_content_fragments_on_chapter_padded"
  end

  create_table "exercises", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "description"
    t.string "text_fragment_order"
    t.string "locale"
    t.text "html"
    t.integer "content_fragment_id"
    t.integer "sort_order"
  end

  create_table "file_attachments", force: :cascade do |t|
    t.string "filename"
    t.string "content_type"
    t.binary "binary_data"
  end

  create_table "text_fragments", force: :cascade do |t|
    t.string "type"
    t.string "text_ltr"
    t.string "key_ltr"
    t.integer "sort_order"
    t.integer "exercise_id"
    t.integer "question_id"
    t.string "text_rtl"
    t.string "key_rtl"
    t.index ["exercise_id"], name: "index_text_fragments_on_exercise_id"
    t.index ["question_id"], name: "index_text_fragments_on_question_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.boolean "is_admin", default: false
    t.string "preferred_locale"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end

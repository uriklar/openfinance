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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130203084812) do

  create_table "transfers", :force => true do |t|
    t.integer  "transfer_id"
    t.integer  "pniya_id"
    t.integer  "year"
    t.string   "section_id"
    t.string   "section_name"
    t.string   "field_id"
    t.string   "field_name"
    t.string   "program_id"
    t.string   "program_name"
    t.string   "request_desc"
    t.decimal  "net"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

end

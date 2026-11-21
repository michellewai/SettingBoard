# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_21_223706) do
  create_table "resets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "wall_section_id", null: false
    t.date "reset_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reset_on"], name: "index_resets_on_reset_on"
    t.index ["wall_section_id", "reset_on"], name: "index_resets_on_wall_section_id_and_reset_on", unique: true
  end

  create_table "routes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "wall_section_id", null: false
    t.string "grade", null: false
    t.string "colour", null: false
    t.date "set_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "setter_id", null: false
    t.index ["setter_id"], name: "index_routes_on_setter_id"
    t.index ["wall_section_id"], name: "index_routes_on_wall_section_id"
  end

  create_table "setters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_setters_on_name", unique: true
  end

  create_table "wall_sections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_wall_sections_on_name", unique: true
  end

  add_foreign_key "resets", "wall_sections"
  add_foreign_key "routes", "setters"
  add_foreign_key "routes", "wall_sections"
end

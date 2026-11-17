# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

WallSection::NAMES_BY_ID.each do |id, name|
  WallSection.find_or_initialize_by(id: id).update!(name: name)
end

# Sample routes, only added when there are none so re-seeding never duplicates or overwrites real data.
if Route.none?
  [
    [ "Back",  "V0", "Yellow", "2026-11-02", "Priya" ],
    [ "Back",  "V1", "Green",  "2026-11-02", "Priya" ],
    [ "Back",  "V3", "Blue",   "2026-11-02", "Marco" ],
    [ "Back",  "V4", "Red",    "2026-11-03", "Marco" ],
    [ "Back",  "V6", "Black",  "2026-11-03", "Jules" ],
    [ "Slab",  "V1", "Pink",   "2026-11-09", "Jules" ],
    [ "Slab",  "V2", "Green",  "2026-11-09", "Priya" ],
    [ "Slab",  "V3", "Orange", "2026-11-09", "Jules" ],
    [ "Slab",  "V5", "White",  "2026-11-10", "Marco" ],
    [ "Cave",  "V4", "Purple", "2026-11-12", "Marco" ],
    [ "Cave",  "V5", "Red",    "2026-11-12", "Tomas" ],
    [ "Cave",  "V7", "Black",  "2026-11-12", "Tomas" ],
    [ "Front", "V0", "Green",  "2026-11-14", "Tomas" ],
    [ "Front", "V2", "Yellow", "2026-11-14", "Priya" ],
    [ "Front", "V3", "Blue",   "2026-11-14", "Jules" ],
    [ "Front", "V5", "Orange", "2026-11-15", "Marco" ]
  ].each do |section_name, grade, colour, set_date, setter_name|
    setter = Setter.find_or_create_by!(name: setter_name)
    WallSection.find_by!(name: section_name).routes.create!(grade:, colour:, set_date:, setter:)
  end
end

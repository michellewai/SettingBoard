# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

WallSection::NAMES_BY_ID.each do |id, name|
  WallSection.find_or_initialize_by(id: id).update!(name: name)
end

# Sample reset schedule: usually one wall a week on a Monday, in id order (Back, Slab, Cave, Front, then
# Back again). Two weeks break the pattern: Slab's reset moves to the Tuesday for an event, and nothing is
# reset in Christmas week. Existing resets are left alone, so re-seeding never duplicates or overwrites them.
{
  "Back"  => [ "2026-10-26", "2026-11-23", "2026-12-28" ],
  "Slab"  => [ "2026-11-02", "2026-12-01", "2027-01-04" ], # 1 Dec is a Tuesday, moved from Monday 30 Nov
  "Cave"  => [ "2026-11-09", "2026-12-07" ],
  "Front" => [ "2026-11-16", "2026-12-14" ]                # then no reset the week of 21 Dec
}.each do |section_name, dates|
  wall_section = WallSection.find_by!(name: section_name)
  dates.each { |date| wall_section.resets.find_or_create_by!(reset_on: Date.parse(date)) }
end

# Sample routes, only added when there are none so re-seeding never duplicates or overwrites real data.
# Every route on a wall is replaced on its reset day, so each set date is that wall's latest reset.
if Route.none?
  {
    "Back" => [
      [ "V0", "Yellow", "Priya" ], [ "V0", "Green",  "Priya" ], [ "V1", "Pink",   "Marco" ], [ "V2", "Blue",   "Marco" ],
      [ "V3", "Orange", "Priya" ], [ "V3", "Purple", "Jules" ], [ "V4", "Red",    "Marco" ], [ "V5", "White",  "Jules" ],
      [ "V6", "Black",  "Jules" ], [ "V7", "Blue",   "Marco" ]
    ],
    "Slab" => [
      [ "V0", "Green",  "Jules" ], [ "V1", "Yellow", "Tomas" ], [ "V1", "Pink",   "Jules" ], [ "V2", "Orange", "Tomas" ],
      [ "V2", "White",  "Priya" ], [ "V3", "Blue",   "Jules" ], [ "V3", "Red",    "Priya" ], [ "V4", "Purple", "Tomas" ],
      [ "V5", "Black",  "Jules" ], [ "V6", "Green",  "Priya" ]
    ],
    "Cave" => [
      [ "V2", "Yellow", "Tomas" ], [ "V3", "Green",  "Marco" ], [ "V4", "Orange", "Tomas" ], [ "V4", "Blue",   "Marco" ],
      [ "V5", "Red",    "Tomas" ], [ "V5", "Pink",   "Marco" ], [ "V6", "Purple", "Tomas" ], [ "V7", "White",  "Marco" ],
      [ "V8", "Black",  "Tomas" ], [ "V9", "Red",    "Marco" ]
    ],
    "Front" => [
      [ "V0", "Green",  "Priya" ], [ "V0", "Yellow", "Tomas" ], [ "V1", "Pink",   "Priya" ], [ "V1", "Orange", "Jules" ],
      [ "V2", "Blue",   "Tomas" ], [ "V2", "White",  "Priya" ], [ "V3", "Purple", "Jules" ], [ "V3", "Red",    "Tomas" ],
      [ "V4", "Black",  "Priya" ], [ "V5", "Blue",   "Jules" ]
    ]
  }.each do |section_name, routes|
    wall_section = WallSection.find_by!(name: section_name)
    set_date = wall_section.last_reset_on

    routes.each do |grade, colour, setter_name|
      setter = Setter.find_or_create_by!(name: setter_name)
      wall_section.routes.create!(grade:, colour:, set_date:, setter:)
    end
  end
end

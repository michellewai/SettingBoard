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
      [ 0, "Yellow", "Priya" ], [ 0, "Green",  "Priya" ], [ 1, "Pink",   "Marco" ], [ 2, "Blue",   "Marco" ],
      [ 3, "Orange", "Priya" ], [ 3, "Purple", "Jules" ], [ 4, "Red",    "Marco" ], [ 5, "White",  "Jules" ],
      [ 6, "Black",  "Jules" ], [ 7, "Blue",   "Marco" ]
    ],
    "Slab" => [
      [ 0, "Green",  "Jules" ], [ 1, "Yellow", "Tomas" ], [ 1, "Pink",   "Jules" ], [ 2, "Orange", "Tomas" ],
      [ 2, "White",  "Priya" ], [ 3, "Blue",   "Jules" ], [ 3, "Red",    "Priya" ], [ 4, "Purple", "Tomas" ],
      [ 5, "Black",  "Jules" ], [ 6, "Green",  "Priya" ]
    ],
    "Cave" => [
      [ 2, "Yellow", "Tomas" ], [ 3, "Green",  "Marco" ], [ 4, "Orange", "Tomas" ], [ 4, "Blue",   "Marco" ],
      [ 5, "Red",    "Tomas" ], [ 5, "Pink",   "Marco" ], [ 6, "Purple", "Tomas" ], [ 7, "White",  "Marco" ],
      [ 8, "Black",  "Tomas" ], [ 9, "Red",    "Marco" ]
    ],
    "Front" => [
      [ 0, "Green",  "Priya" ], [ 0, "Yellow", "Tomas" ], [ 1, "Pink",   "Priya" ], [ 1, "Orange", "Jules" ],
      [ 2, "Blue",   "Tomas" ], [ 2, "White",  "Priya" ], [ 3, "Purple", "Jules" ], [ 3, "Red",    "Tomas" ],
      [ 4, "Black",  "Priya" ], [ 5, "Blue",   "Jules" ]
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

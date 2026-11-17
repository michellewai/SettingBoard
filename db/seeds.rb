# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

WallSection::NAMES_BY_ID.each do |id, name|
  WallSection.find_or_initialize_by(id: id).update!(name: name)
end

# Sample routes, only added when there are none so re-seeding never duplicates or overwrites real data.
#
# Walls are reset one per week, every Monday, in id order (Back, Slab, Cave, Front, then Back again),
# and every route on a wall is replaced on its reset day. Back was reset on Monday 26 October 2026.
FIRST_BACK_RESET = Date.new(2026, 10, 26)

# The Monday a wall was last reset, on or before today.
last_reset_date = ->(wall_section) do
  first_reset = FIRST_BACK_RESET + (wall_section.id - 1).weeks
  cycles = [ (Date.current - first_reset).to_i / 28, 0 ].max
  first_reset + (cycles * 4).weeks
end

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
    set_date = last_reset_date.(wall_section)

    routes.each do |grade, colour, setter_name|
      setter = Setter.find_or_create_by!(name: setter_name)
      wall_section.routes.create!(grade:, colour:, set_date:, setter:)
    end
  end
end

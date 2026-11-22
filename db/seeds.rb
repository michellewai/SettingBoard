# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

WallSection::NAMES_BY_ID.each do |id, name|
  WallSection.find_or_initialize_by(id: id).update!(name: name)
end

# Sample reset schedule: usually one wall a week on a Monday, in id order (Back, Slab, Cave, Front, then
# Back again), starting with a past rotation so there is route history. Two weeks break the pattern: Slab's
# reset moves to the Tuesday for an event, and nothing is reset in Christmas week. Existing resets are left
# alone, so re-seeding never duplicates or overwrites them.
{
  "Back"  => [ "2026-09-28", "2026-10-26", "2026-11-23", "2026-12-28" ],
  "Slab"  => [ "2026-10-05", "2026-11-02", "2026-12-01", "2027-01-04" ], # 1 Dec is a Tuesday, moved from Monday 30 Nov
  "Cave"  => [ "2026-10-12", "2026-11-09", "2026-12-07" ],
  "Front" => [ "2026-10-19", "2026-11-16", "2026-12-14" ]                # then no reset the week of 21 Dec
}.each do |section_name, dates|
  wall_section = WallSection.find_by!(name: section_name)
  dates.each { |date| wall_section.resets.find_or_create_by!(reset_on: Date.parse(date)) }
end

# Sample routes, only added when there are none so re-seeding never duplicates or overwrites real data.
# Each wall gets the routes from its previous reset, retired with WallSection#reset! on its latest reset,
# then the routes up now, set on that latest reset.
if Route.none?
  previous_routes = {
    "Back"  => [ [ 1, "Green", "Marco" ], [ 2, "Red", "Priya" ], [ 3, "Blue", "Jules" ], [ 4, "Yellow", "Marco" ], [ 6, "Pink", "Priya" ], [ 8, "Black", "Jules" ] ],
    "Slab"  => [ [ 0, "Blue", "Tomas" ], [ 1, "White", "Jules" ], [ 2, "Red", "Priya" ], [ 2, "Purple", "Tomas" ], [ 3, "Orange", "Jules" ], [ 5, "Green", "Priya" ] ],
    "Cave"  => [ [ 3, "Pink", "Marco" ], [ 5, "Blue", "Tomas" ], [ 6, "Yellow", "Marco" ], [ 7, "Green", "Tomas" ], [ 8, "Red", "Marco" ], [ 10, "Black", "Tomas" ] ],
    "Front" => [ [ 0, "White", "Jules" ], [ 1, "Red", "Priya" ], [ 2, "Green", "Tomas" ], [ 3, "Yellow", "Jules" ], [ 4, "Orange", "Priya" ], [ 4, "Pink", "Tomas" ] ]
  }

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
    previous_set_date = wall_section.last_reset_on(set_date.prev_day)
    create_routes = lambda do |list, date|
      list.each do |grade, colour, setter_name|
        wall_section.routes.create!(grade:, colour:, set_date: date, setter: Setter.find_or_create_by!(name: setter_name))
      end
    end

    if previous_set_date
      create_routes.call(previous_routes.fetch(section_name), previous_set_date)
      wall_section.reset!(on: set_date)
    end
    create_routes.call(routes, set_date)
  end
end

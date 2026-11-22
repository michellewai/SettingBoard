# Keep routes after a reset instead of replacing them: retired_on records the day a route came down,
# so the grade mix and setter history stay in the database. Null means the route is still up.
class AddRetiredOnToRoutes < ActiveRecord::Migration[8.1]
  def change
    add_column :routes, :retired_on, :date
    add_check_constraint :routes, "retired_on IS NULL OR retired_on >= set_date", name: "routes_retired_after_set"
  end
end

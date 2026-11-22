# Keep grades within the gym's V0–V10 scale in the database too, not only in the Route validation,
# so a console or script can't store a grade the Grades tab would never count.
# The range matches Route::GRADES, written out because migrations shouldn't depend on models.
class AddGradeRangeCheckToRoutes < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :routes, "grade BETWEEN 0 AND 10", name: "routes_grade_range"
  end
end

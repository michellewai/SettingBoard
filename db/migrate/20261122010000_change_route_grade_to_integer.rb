# Store grades as numbers ("V5" becomes 5) so they sort and count in grade order.
class ChangeRouteGradeToInteger < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE routes SET grade = SUBSTRING(grade, 2) WHERE grade LIKE 'V%'"
    change_column :routes, :grade, :integer, null: false
  end

  def down
    change_column :routes, :grade, :string, null: false
    execute "UPDATE routes SET grade = CONCAT('V', grade)"
  end
end

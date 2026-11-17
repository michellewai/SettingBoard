# Moves routes from a free-text setter name to a reference to the setters table,
# creating a Setter for each distinct name already in use.
class ReplaceRouteSetterNameWithSetterId < ActiveRecord::Migration[8.1]
  def up
    add_reference :routes, :setter, foreign_key: true

    execute <<~SQL
      INSERT INTO setters (name, created_at, updated_at)
      SELECT DISTINCT routes.setter, NOW(6), NOW(6) FROM routes
      WHERE NOT EXISTS (SELECT 1 FROM setters WHERE setters.name = routes.setter)
    SQL
    execute <<~SQL
      UPDATE routes INNER JOIN setters ON setters.name = routes.setter
      SET routes.setter_id = setters.id
    SQL

    change_column_null :routes, :setter_id, false
    remove_column :routes, :setter
  end

  def down
    add_column :routes, :setter, :string

    execute <<~SQL
      UPDATE routes INNER JOIN setters ON setters.id = routes.setter_id
      SET routes.setter = setters.name
    SQL

    change_column_null :routes, :setter, false
    remove_reference :routes, :setter, foreign_key: true
  end
end

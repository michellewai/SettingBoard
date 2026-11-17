class CreateRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :routes do |t|
      t.references :wall_section, null: false, foreign_key: true
      t.string :grade, null: false
      t.string :colour, null: false
      t.date :set_date, null: false
      t.string :setter, null: false

      t.timestamps
    end
  end
end

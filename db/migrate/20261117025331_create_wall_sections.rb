class CreateWallSections < ActiveRecord::Migration[8.1]
  def change
    create_table :wall_sections do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :wall_sections, :name, unique: true
  end
end

class CreateSetters < ActiveRecord::Migration[8.1]
  def change
    create_table :setters do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :setters, :name, unique: true
  end
end

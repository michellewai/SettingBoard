class CreateResets < ActiveRecord::Migration[8.1]
  def change
    create_table :resets do |t|
      t.references :wall_section, null: false, foreign_key: true, index: false
      t.date :reset_on, null: false

      t.timestamps
    end

    # A wall is reset at most once a day; two walls may share a day. This index also covers
    # lookups by wall section, so t.references skips its own.
    add_index :resets, [ :wall_section_id, :reset_on ], unique: true
    add_index :resets, :reset_on
  end
end

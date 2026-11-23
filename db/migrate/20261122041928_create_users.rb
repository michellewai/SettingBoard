# Sign-in accounts for setters. Each account belongs to exactly one setter, so the unique setter_id
# lets forms default to "you" and keeps one setter from having two logins.
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.references :setter, null: false, foreign_key: true, index: { unique: true }
      t.string :email_address, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end

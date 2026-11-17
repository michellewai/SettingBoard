# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

WallSection::NAMES_BY_ID.each do |id, name|
  WallSection.find_or_initialize_by(id: id).update!(name: name)
end

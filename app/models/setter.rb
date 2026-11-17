class Setter < ApplicationRecord
  has_many :routes, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end

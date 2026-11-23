class Setter < ApplicationRecord
  has_many :routes, dependent: :restrict_with_error
  has_one :user, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end

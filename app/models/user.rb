# A setter's sign-in account. Accounts are created by the head setter in the console; there is no
# sign-up page and no password reset by email.
class User < ApplicationRecord
  has_secure_password
  belongs_to :setter
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :setter, uniqueness: true
  # has_secure_password already requires a password and caps its length. Nil means it isn't being changed.
  validates :password, length: { minimum: 12 }, allow_nil: true

  delegate :name, to: :setter
end

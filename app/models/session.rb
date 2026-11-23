# A user's sign-in on one browser. It ends at sign-out or after LIFETIME, whichever comes first.
class Session < ApplicationRecord
  LIFETIME = 30.days

  belongs_to :user

  scope :active, -> { where(created_at: LIFETIME.ago..) }
end

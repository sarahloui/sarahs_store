class Offer < ApplicationRecord
  has_one :order
  enum :status, { available: 0, on_hold: 1, accepted: 2}
end

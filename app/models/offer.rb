class Offer < ApplicationRecord
  has_one :order
  belongs_to :product
  enum :status, { available: 0, on_hold: 1, accepted: 2}
end

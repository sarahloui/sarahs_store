class Product < ApplicationRecord
  has_one_attached :image
  has_one :order
  enum :status, { available: 0, on_hold: 1, sold: 2}
end

class Offer < ApplicationRecord
  has_one :order
  belongs_to :product
  enum :status, { available: 0, on_hold: 1, accepted: 2}

  def complete
    self.update(status: 2, current: false)
    self.product.increment!(:number_sold)
  end
end

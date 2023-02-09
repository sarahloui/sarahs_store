class Offer < ApplicationRecord
  MAX_CART_HOLD_TIME = 60
  has_one :order
  belongs_to :product
  enum :status, { available: 0, on_hold: 1, accepted: 2}

  def complete
    self.update(status: 2, current: false)
    self.product.increment_number_sold
  end

  def cart_time_limit_exceeded?
    self.start_time.since(MAX_CART_HOLD_TIME)<DateTime.now
  end

end
